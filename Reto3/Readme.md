# Reto: Hacer agregaciones y vistas de la tabla country.

## Requisitos
  - Tener una instancia local de MySQL Server corriendo con la base de datos sakila lista

## Ejecución del script

Abrir MYSQL Workbench y correr el script 'Agregaciones y vistas.sql'

## Pregunta

### ¿Qué relación tienen los datos maestros con las dimensiones en un modelo multidimensional?

Los datos maestros son los datos criticos del negocio por ejemplo personas, inventario, geografias, etc. y las dimensiones son las tablas que proporcionan contexto a las tablas de hechos.
La relación es que ambos ayduan a ver en contexto las tablas de hechos o transacciones dependiendo si estamos en el mundo transaccional o el mundo analítico.
Por ejemplo, en un retail, en la tabla de hechos ventas podemos tener las dimensiones persona o producto. Si vemos, estas dimensiones son datos críticos de la organización o datos maestros.
