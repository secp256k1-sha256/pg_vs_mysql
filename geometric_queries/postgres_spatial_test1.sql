-- PostgreSQL 17 with PostGIS Test Script

-- Create extension if not exists
CREATE EXTENSION IF NOT EXISTS postgis;

-- Create test table
CREATE TABLE locations (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    category VARCHAR(50),
    geom GEOMETRY(POINT, 4326),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Generate test data (1 million points)
DO $$
DECLARE
    categories TEXT[] := ARRAY['restaurant', 'hotel', 'park', 'shop', 'school'];
    i INT;
BEGIN
    FOR i IN 1..1000000 LOOP
        INSERT INTO locations (name, category, geom)
        VALUES (
            'Location ' || i,
            categories[1 + (i % 5)],
            ST_SetSRID(ST_MakePoint(
                -180 + 360 * random(),
                -90 + 180 * random()
            ), 4326)
        );
        
        IF i % 10000 = 0 THEN
            RAISE NOTICE 'Inserted % records', i;
            COMMIT;
        END IF;
    END LOOP;
END $$;

-- Create spatial index
CREATE INDEX idx_locations_geom ON locations USING GIST(geom);

-- Create index on category for faster filtering
CREATE INDEX idx_locations_category ON locations(category);

-- update statistics
ANALYZE locations;

-- Find all restaurants within 5km of a specific point, ordered by distance
EXPLAIN (ANALYZE, BUFFERS)
SELECT 
    id, 
    name,
    category,
    ST_Distance(
        geom::geography, 
        ST_SetSRID(ST_MakePoint(-57.466861, -68.298504), 4326)::geography
    ) AS distance_meters
FROM 
    locations
WHERE 
    category = 'restaurant' AND
    ST_DWithin(
        geom::geography, 
        ST_SetSRID(ST_MakePoint(-57.466861, -68.298504), 4326)::geography,
        5000
    )
ORDER BY 
    distance_meters
;
