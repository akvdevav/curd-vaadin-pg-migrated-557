## 🛍️ Tracking Customer Movement for Store Optimization with PostGIS
This example extends the basic PostGIS setup to simulate and analyze customer movement within a retail store. By tracking user paths and interactions with different store zones and products, we can gain valuable insights to optimize store layouts, product placement, and overall customer experience.

### 🚀 Step 1: Run PostgreSQL + PostGIS with Bitnami (Podman)
First, ensure your PostgreSQL instance with PostGIS is running.

```
docker run --rm -it --name postgres \
  -e POSTGRESQL_PASSWORD=postgres \
  -e POSTGRESQL_DATABASE=postgres \
  -p 5432:5432 \
  bitnami/postgresql:latest
```


### ⏳ Wait a few seconds for the database to start, then connect to it:

```
docker exec -it postgres psql -U postgres -d postgres
```

### 🧱 Step 2: Enable PostGIS Inside the psql prompt:

If you haven't already, enable the PostGIS extensions.

```
CREATE EXTENSION postgis;
CREATE EXTENSION postgis_topology;
```


### 🗺️ Step 3: Define Store Layout, Product Locations, and User Tracking Tables
We'll create tables to represent the store's physical layout (zones), the location of products, and to record user movement. We'll use GEOMETRY with SRID 4326 for simplicity, treating the store as a flat 2D plane.

#### 3.1 Create store_zones Table (Polygons for Departments/Areas)

This table defines different areas or departments within your store.

```
CREATE TABLE store_zones (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    boundary GEOMETRY(POLYGON, 4326) NOT NULL
);
```

- Insert example store zones (using arbitrary coordinates for a hypothetical store layout)
- Imagine a store grid, e.g., 0,0 to 100,100 units

```
INSERT INTO store_zones (name, description, boundary) VALUES
('Entrance', 'Main entrance and greeting area', ST_GeomFromText('POLYGON((0 0, 20 0, 20 20, 0 20, 0 0))', 4326)),
('Produce', 'Fresh fruits and vegetables', ST_GeomFromText('POLYGON((0 20, 30 20, 30 50, 0 50, 0 20))', 4326)),
('Dairy', 'Milk, cheese, and yogurt products', ST_GeomFromText('POLYGON((30 20, 60 20, 60 50, 30 50, 30 20))', 4326)),
('Bakery', 'Freshly baked goods', ST_GeomFromText('POLYGON((60 20, 100 20, 100 50, 60 50, 60 20))', 4326)),
('Checkout', 'Cashier and exit area', ST_GeomFromText('POLYGON((80 0, 100 0, 100 20, 80 20, 80 0))', 4326)),
('Electronics', 'Electronics department', ST_GeomFromText('POLYGON((0 50, 50 50, 50 100, 0 100, 0 50))', 4326)),
('Apparel', 'Clothing and accessories', ST_GeomFromText('POLYGON((50 50, 100 50, 100 100, 50 100, 50 50))', 4326));
```


#### 3.2 Create product_locations Table (Points for Individual Products)

This table stores the specific locations of key products or product categories.

```
CREATE TABLE product_locations (
    id SERIAL PRIMARY KEY,
    product_name TEXT NOT NULL,
    category TEXT,
    location GEOMETRY(POINT, 4326) NOT NULL
);
```


- Insert example product locations within the defined zones

```
INSERT INTO product_locations (product_name, category, location) VALUES
('Apples', 'Produce', ST_GeomFromText('POINT(15 35)', 4326)),
('Milk (Whole)', 'Dairy', ST_GeomFromText('POINT(45 30)', 4326)),
('Artisan Bread', 'Bakery', ST_GeomFromText('POINT(75 40)', 4326)),
('Smartphone X', 'Electronics', ST_GeomFromText('POINT(25 75)', 4326)),
('T-Shirt (Mens)', 'Apparel', ST_GeomFromText('POINT(70 80)', 4326)),
('Yogurt (Greek)', 'Dairy', ST_GeomFromText('POINT(50 45)', 4326)),
('Laptop Pro', 'Electronics', ST_GeomFromText('POINT(10 60)', 4326));
```

#### 3.3 Create user_visits Table (Individual User Location Points)

This table captures individual location pings from user devices (e.g., Wi-Fi, Bluetooth beacons).

```
CREATE TABLE user_visits (
    id SERIAL PRIMARY KEY,
    user_id TEXT NOT NULL,
    visit_time TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    location GEOMETRY(POINT, 4326) NOT NULL
);
```

- Simulate a user's movement through the store
- User 101: Enters, goes to Produce, then Dairy, then Bakery, then Checkout

```
INSERT INTO user_visits (user_id, location) VALUES
('user_101', ST_GeomFromText('POINT(10 10)', 4326)), -- Entrance
('user_101', ST_GeomFromText('POINT(10 25)', 4326)), -- Produce
('user_101', ST_GeomFromText('POINT(15 30)', 4326)), -- Produce
('user_101', ST_GeomFromText('POINT(35 30)', 4326)), -- Dairy
('user_101', ST_GeomFromText('POINT(40 40)', 4326)), -- Dairy
('user_101', ST_GeomFromText('POINT(65 45)', 4326)), -- Bakery
('user_101', ST_GeomFromText('POINT(85 15)', 4326)), -- Checkout
('user_101', ST_GeomFromText('POINT(90 10)', 4326)); -- Checkout
```

- Simulate another user's movement
- User 102: Enters, goes to Electronics, then Apparel, then Checkout

```
INSERT INTO user_visits (user_id, location) VALUES
('user_102', ST_GeomFromText('POINT(10 10)', 4326)), -- Entrance
('user_102', ST_GeomFromText('POINT(20 55)', 4326)), -- Electronics
('user_102', ST_GeomFromText('POINT(30 70)', 4326)), -- Electronics
('user_102', ST_GeomFromText('POINT(60 70)', 4326)), -- Apparel
('user_102', ST_GeomFromText('POINT(75 85)', 4326)), -- Apparel
('user_102', ST_GeomFromText('POINT(85 15)', 4326)); -- Checkout
```


#### 3.4 Create user_paths Table (Aggregated User Paths as LINESTRINGs)

This table can store aggregated paths for easier analysis of full journeys.

```
CREATE TABLE user_paths (
    id SERIAL PRIMARY KEY,
    user_id TEXT NOT NULL,
    path_start_time TIMESTAMP WITH TIME ZONE,
    path_end_time TIMESTAMP WITH TIME ZONE,
    path GEOMETRY(LINESTRING, 4326) NOT NULL
);
```


- Example: Aggregate user_101's path from user_visits (this would typically be done by an application logic)
- For demonstration, we'll manually create a LINESTRING for a user's journey.
- In a real application, you'd group user_visits by user_id and time window, then use ST_MakeLine.

```
INSERT INTO user_paths (user_id, path_start_time, path_end_time, path) VALUES
('user_101', '2025-06-27 08:00:00+00', '2025-06-27 08:05:00+00',
    ST_GeomFromText('LINESTRING(10 10, 10 25, 15 30, 35 30, 40 40, 65 45, 85 15, 90 10)', 4326));
```

```
INSERT INTO user_paths (user_id, path_start_time, path_end_time, path) VALUES
('user_102', '2025-06-27 08:10:00+00', '2025-06-27 08:14:00+00',
    ST_GeomFromText('LINESTRING(10 10, 20 55, 30 70, 60 70, 75 85, 85 15)', 4326));
```


### 🔎 Step 4: Analyze User Behavior with Spatial Queries

Now, let's use PostGIS to extract insights from the collected data.

#### 4.1 Hotspot Analysis: Identify Frequently Visited Zones

Find which zones are most frequently entered or passed through by users.

- Count how many user visits fall within each zone

```
SELECT
    sz.name AS zone_name,
    COUNT(uv.id) AS total_visits_in_zone
FROM
    store_zones sz
JOIN
    user_visits uv ON ST_Contains(sz.boundary, uv.location)
GROUP BY
    sz.name
ORDER BY
    total_visits_in_zone DESC;
```


- Identify zones that user paths intersect (indicating traffic flow)

```
SELECT
    sz.name AS zone_name,
    COUNT(DISTINCT up.user_id) AS unique_users_passing_through
FROM
    store_zones sz
JOIN
    user_paths up ON ST_Intersects(sz.boundary, up.path)
GROUP BY
    sz.name
ORDER BY
    unique_users_passing_through DESC;
```

#### 4.2 Dwell Time Analysis: Calculate Time Spent in Zones

This requires more sophisticated application logic to calculate time differences between entry and exit points, but we can approximate it by counting consecutive points within a zone.

- This query approximates dwell time by counting consecutive points in a zone.
- A more accurate approach would involve tracking entry/exit timestamps per zone per user.

```
SELECT
    sz.name AS zone_name,
    uv.user_id,
    COUNT(uv.id) AS points_in_zone,
    -- If points are roughly 1 unit of time apart, this gives an approximation
    COUNT(uv.id) * 1 AS estimated_time_units
FROM
    store_zones sz
JOIN
    user_visits uv ON ST_Contains(sz.boundary, uv.location)
GROUP BY
    sz.name, uv.user_id
ORDER BY
    zone_name, estimated_time_units DESC;
```


#### 4.3 Path Analysis: Identify Common Routes and Product Interactions

- Find which zones a specific user visited in order (requires ordering by time)

```
SELECT
    uv.user_id,
    sz.name AS zone_visited,
    uv.visit_time
FROM
    user_visits uv
JOIN
    store_zones sz ON ST_Contains(sz.boundary, uv.location)
WHERE
    uv.user_id = 'user_101'
ORDER BY
    uv.visit_time;
```

- Find products a user passed near or viewed (within a certain buffer distance)

```
SELECT
    up.user_id,
    pl.product_name,
    pl.category,
    ST_Distance(up.path, pl.location) AS distance_to_path -- Distance from path to product
FROM
    user_paths up, product_locations pl
WHERE
    ST_DWithin(up.path, pl.location, 5) -- Within 5 units of the path
ORDER BY
    up.user_id, distance_to_path;
```


#### 4.4 Co-location Analysis: Discover Products Frequently Viewed Together
- Find pairs of products that are frequently visited by the same users within a short time frame
- This is a conceptual query; actual implementation would be more complex, involving time windows.
- Here, we find products that are "close" to each other on the same user's path.

```
SELECT
    p1.product_name AS product1,
    p2.product_name AS product2,
    COUNT(DISTINCT up.user_id) AS users_viewed_both
FROM
    user_paths up
JOIN
    product_locations p1 ON ST_DWithin(up.path, p1.location, 5) -- Product 1 near path
JOIN
    product_locations p2 ON ST_DWithin(up.path, p2.location, 5) -- Product 2 near path
WHERE
    p1.id != p2.id -- Ensure it's not the same product
GROUP BY
    p1.product_name, p2.product_name
ORDER BY
    users_viewed_both DESC
LIMIT 10;
```


### 💡 Step 5: Inform Store Layout and Product Placement Changes

The insights from the spatial queries can directly inform strategic decisions:

Optimize Product Placement:

If Milk and Cereal are frequently viewed together (co-location analysis), consider placing them closer to encourage impulse buys or improve shopping convenience.

If a product (Smartphone X) is in a high-traffic zone but has low dwell time, its display might need improvement.

Redesign Store Layout:

**Hotspot Analysis:** If the Checkout zone is consistently a major hotspot, it confirms its function. If Electronics has unexpectedly high traffic but low sales, investigate why.

**Dwell Time Analysis:** If customers spend very little time in the Produce section, it might indicate poor layout, lack of appealing displays, or difficulty finding items. Conversely, high dwell time in a non-destination zone might indicate confusion or bottlenecks.

**Path Analysis:** If many users take a long, winding path to reach a popular product, consider creating a more direct route. If a certain aisle is consistently avoided, it might be a "dead zone" needing revitalization.

Staffing Optimization:

High-traffic areas or zones with high dwell time might require more staff presence.

Promotional Effectiveness:

Track if promotional displays (treated as temporary "product locations") lead to increased traffic or dwell time in their vicinity.

Example SQL for Actionable Insights:

- Identify zones with low average dwell time (conceptual, based on point count)

```
SELECT
    sz.name AS zone_name,
    AVG(points_in_zone) AS avg_points_per_user_visit
FROM (
    SELECT
        sz.name,
        uv.user_id,
        COUNT(uv.id) AS points_in_zone
    FROM
        store_zones sz
    JOIN
        user_visits uv ON ST_Contains(sz.boundary, uv.location)
    GROUP BY
        sz.name, uv.user_id
) AS zone_user_points
GROUP BY
    sz.name
ORDER BY
    avg_points_per_user_visit ASC; -- Zones with lower average points might need attention
```

- Find products that are frequently passed by but not "dwelled" on (conceptual)
- This would involve comparing products near paths with products that have associated dwell time.
- For example, if 'Apples' are near many user paths but few users actually stop in the 'Produce' zone for long.

```
SELECT
    pl.product_name,
    COUNT(DISTINCT up.user_id) AS users_passed_by
FROM
    product_locations pl
JOIN
    user_paths up ON ST_DWithin(up.path, pl.location, 5)
GROUP BY
    pl.product_name
ORDER BY
    users_passed_by DESC;
```

This extended example provides a robust framework for using PostGIS to analyze customer movement in a store, offering valuable data-driven insights for strategic store optimization.