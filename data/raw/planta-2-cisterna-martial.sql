-- Datos de cisterna_martial_volumen_porcentaje, Planta 2, desde 2025-01-01.
-- Fuente: ml_datos.observaciones de la base remota; 0 lecturas.
-- SQL de PostgreSQL para una tabla separada de las tablas operativas.
BEGIN;
CREATE SCHEMA IF NOT EXISTS intercambio_predicciones;
CREATE TABLE IF NOT EXISTS intercambio_predicciones.planta_2_cisterna_martial (
  fecha_hora timestamptz PRIMARY KEY,
  cisterna_martial_volumen_porcentaje numeric NOT NULL
);
-- No se encontraron valores; la tabla queda sin filas.
COMMIT;
