#! /usr/bin/env python
# -*- coding: utf-8 -*-

from sqlalchemy import create_engine
import numpy as np
import json
import pandas as pd

# Variables de conexión
engine2 = create_engine('mysql+mysqlconnector://root:root@127.0.0.1/sakila')
connection2 = engine2.connect()

# Ejecutar el query inicial que trae la antigua tabla de paises
countrys_select = connection2.execute("SELECT * FROM SAKILA.COUNTRY")
df_sakila_countrys = pd.DataFrame(countrys_select.fetchall())

# Traer los paises que se van a agregar a la nueva tabla de un archivo all.json
with open("all.json",encoding="utf8") as datafile:
    data = json.load(datafile)
json_countrys_df = pd.DataFrame(data)

# renombrar las columnas del dataframe de paises antiguos
df_sakila_countrys['country_id'] = df_sakila_countrys[0]
df_sakila_countrys['name'] = df_sakila_countrys[1]
df_sakila_countrys['last_update'] = df_sakila_countrys[2]

# Eliminar las antiguas columnas
del df_sakila_countrys[0]
del df_sakila_countrys[1]
del df_sakila_countrys[2]

# Convertir a strings los campos que son listas
json_countrys_df['topLevelDomain'] = json_countrys_df['topLevelDomain'].apply(lambda x: json.dumps(x))
json_countrys_df['callingCodes'] = json_countrys_df['callingCodes'].apply(lambda x: json.dumps(x))
json_countrys_df['altSpellings'] = json_countrys_df['altSpellings'].apply(lambda x: json.dumps(x))
json_countrys_df['latlng'] = json_countrys_df['latlng'].apply(lambda x: json.dumps(x))
json_countrys_df['timezones'] = json_countrys_df['timezones'].apply(lambda x: json.dumps(x))
json_countrys_df['borders'] = json_countrys_df['borders'].apply(lambda x: json.dumps(x))
json_countrys_df['currencies'] = json_countrys_df['currencies'].apply(lambda x: json.dumps(x))
json_countrys_df['languages'] = json_countrys_df['languages'].apply(lambda x: json.dumps(x))
json_countrys_df['translations'] = json_countrys_df['translations'].apply(lambda x: json.dumps(x))
json_countrys_df['regionalBlocs'] = json_countrys_df['regionalBlocs'].apply(lambda x: json.dumps(x))

# Hacer un left join del dataframe de paises antiguos con el dataframe de paises nuevos.
# Esto nos trae todos los paises que ya existian añadiendo los campos que tenían estos paises en el json.
left_joined_df = pd.merge(left=json_countrys_df, right=df_sakila_countrys,
                            left_on='name', right_on='name',how='left')
# Guardar estos paises en una tabla.
left_joined_df.to_sql('country_ext', connection2, if_exists='replace', index= False, index_label = 'country_id')

# Hacer un outer join del dataframe de paises antiguos con el dataframe de paises nuevos. Esto nos trae todos los paises, nuevos y viejos.
outer_joined_df = pd.merge(left=json_countrys_df,right=df_sakila_countrys,
                            left_on="name", right_on='name',how='outer')

# Obtener solo los paises que no han sido insertados, es decir,
# los que estan en el outer join y no estan en el left join.
merged = outer_joined_df.merge(right=left_joined_df, how='left', indicator=True)


lefting_countrys = merged[merged['_merge']=='left_only']

# limpieza de columnas
del lefting_countrys['_merge']
del lefting_countrys['country_id']

# Quitar parametros de configuración para evitar excepciones y agregar
# la columna de indices correspondiente al dataframe que falta por insertar.
pd.options.mode.chained_assignment = None
lefting_countrys['country_id'] = list(range(len(left_joined_df)+1,
                                            len(outer_joined_df)+1))

# Insertar los paises nuevos en la tabla
lefting_countrys.to_sql('country_ext', connection2, if_exists='append',
                        index= False, index_label = 'country_id')
