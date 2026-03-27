-- Table: public.products_search

-- DROP TABLE IF EXISTS public.products_search;

-- Step 1: Create the function first
CREATE OR REPLACE FUNCTION public.products_title_tsvector_trigger()
RETURNS TRIGGER AS $$
BEGIN
    NEW.title_tsv := to_tsvector('pg_catalog.english', NEW.title);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Step 2: Then, create your table and trigger (as you had it)
CREATE TABLE IF NOT EXISTS public.products_search
(
    prod_id serial NOT NULL,
    category integer NOT NULL,
    title character varying(255) COLLATE pg_catalog."default" NOT NULL,
    actor character varying(255) COLLATE pg_catalog."default" NOT NULL,
    price numeric(38,2) NOT NULL,
    special smallint,
    common_prod_id integer NOT NULL,
    title_tsv tsvector
);

ALTER TABLE IF EXISTS public.products_search
    OWNER to postgres;

-- Index: products_title_tsv_idx
CREATE INDEX IF NOT EXISTS products_title_tsv_idx
    ON public.products_search USING gin
    (title_tsv);

-- Trigger: tsvector_update_title
CREATE OR REPLACE TRIGGER tsvector_update_title
    BEFORE INSERT OR UPDATE
    ON public.products_search
    FOR EACH ROW
    EXECUTE FUNCTION public.products_title_tsvector_trigger();

-- ALTER TABLE public.products_search ADD COLUMN title_tsv tsvector;

-- UPDATE public.products_search SET title_tsv = to_tsvector('english', title);

-- CREATE INDEX products_title_tsv_idx ON public.products_search USING GIN (title_tsv);



-- CREATE FUNCTION products_title_tsvector_trigger() RETURNS trigger AS $$
-- BEGIN
--   NEW.title_tsv := to_tsvector('english', NEW.title);
--   RETURN NEW;
-- END
-- $$ LANGUAGE plpgsql;

-- CREATE TRIGGER tsvector_update_title BEFORE INSERT OR UPDATE ON public.products_search
-- FOR EACH ROW EXECUTE FUNCTION products_title_tsvector_trigger();

-- delete from public.products_search;

-- insert into public.products_search (select * from public.products);

INSERT INTO public.products_search (
    prod_id,
    category,
    title,
    actor,
    price,
    special,
    common_prod_id
)
SELECT
    -- Dynamically calculate a unique ID for each row.
    -- COALESCE handles the case where the table might be empty (MAX(prod_id) would be NULL).
    -- gs.i provides a sequential number for each generated row.
    COALESCE((SELECT MAX(prod_id) FROM public.products_search), 0) + gs.i,

    -- category: Random integer between 1 and 10
    FLOOR(RANDOM() * 10 + 1)::INTEGER,

    -- title: Combines a prefix, an adjective, and a specific product noun
    CASE FLOOR(RANDOM() * 7) -- More prefixes for variety
        WHEN 0 THEN 'Premium '
        WHEN 1 THEN 'High-Quality '
        WHEN 2 THEN 'Eco-Friendly '
        WHEN 3 THEN 'Designer '
        WHEN 4 THEN 'Comfortable '
        WHEN 5 THEN 'Durable '
        ELSE 'Stylish '
    END ||
    CASE FLOOR(RANDOM() * 10) -- More adjectives
        WHEN 0 THEN 'Cotton '
        WHEN 1 THEN 'Soft '
        WHEN 2 THEN 'Natural '
        WHEN 3 THEN 'Organic '
        WHEN 4 THEN 'Smart '
        WHEN 5 THEN 'Handcrafted '
        WHEN 6 THEN 'Luxurious '
        WHEN 7 THEN 'Compact '
        WHEN 8 THEN 'Wireless '
        ELSE 'Vintage '
    END ||
    (ARRAY[

        -- Clothing & Apparel (Expanded)
        'T-Shirt', 'Jeans', 'Dress Shirt', 'Sweater', 'Hoodie', 'Polo Shirt', 'Blouse', 'Skirt', 'Dress',
        'Leggings', 'Shorts', 'Pants', 'Jacket', 'Coat', 'Vest', 'Socks', 'Underwear', 'Pajamas',
        'Scarf', 'Hat', 'Beanie', 'Gloves', 'Swimsuit', 'Workout Top', 'Running Shorts', 'Yoga Pants',


        -- Footwear
		'Sneakers', 'Running Shoes', 'Walking Shoes', 'Boots', 'Dress Shoes', 'Sandals', 'Slippers',
		'Flats', 'Heels', 'Athletic Cleats', 'Hiking Boots',


        -- Accessories (Personal)
		'Backpack', 'Handbag', 'Crossbody Bag', 'Wallet', 'Belt', 'Sunglasses', 'Reading Glasses',
		'Watch', 'Necklace', 'Bracelet', 'Earrings', 'Ring', 'Hair Clip', 'Hair Tie', 'Scarf',
		'Umbrella', 'Keychain', 'Travel Pillow',


        -- Home Goods & Decor (Expanded)
		'Coffee Maker', 'Toaster', 'Blender', 'Mixer', 'Food Processor', 'Air Fryer', 'Rice Cooker',
		'Electric Kettle', 'Vacuum Cleaner', 'Robot Vacuum', 'Mop', 'Broom', 'Dustpan', 'Cleaning Wipes',
		'Dish Soap', 'Laundry Detergent', 'Fabric Softener', 'Trash Bags', 'Paper Towels', 'Toilet Paper',
		'Pillow', 'Blanket', 'Duvet Cover Set', 'Sheet Set', 'Towel Set', 'Bath Mat', 'Shower Curtain',
		'Candle', 'Diffuser', 'Vase', 'Picture Frame', 'Mirror', 'Wall Art', 'Decorative Tray',
		'Mug Set', 'Plate Set', 'Bowl Set', 'Cutlery Set', 'Wine Glasses', 'Water Glasses',
		'Frying Pan', 'Saucepan', 'Stock Pot', 'Baking Sheet', 'Mixing Bowl', 'Cutting Board',
		'Storage Container Set', 'Food Storage Bags', 'Comforter', 'Area Rug', 'Curtains', 'Blinds',
		'Desk Lamp', 'Floor Lamp', 'Table Lamp', 'Bookshelf', 'Desk Chair', 'Dining Table', 'Coffee Table',
		'Side Table', 'Sofa', 'Armchair', 'Pouf', 'Ottoman', 'Clock', 'Alarm Clock', 'Smart Speaker',
		'Smart Light Bulb', 'Thermostat', 'Door Mat', 'Welcome Mat', 'Plant Pot', 'Artificial Plant',


        -- Kitchen & Dining (Specific)
		'Espresso Machine', 'French Press', 'Tea Kettle', 'Waffle Maker', 'Toaster Oven', 'Slow Cooker',
		'Pressure Cooker', 'Measuring Cups', 'Measuring Spoons', 'Kitchen Scale', 'Oven Mitts',
		'Apron', 'Spice Rack', 'Salt and Pepper Shakers', 'Corkscrew', 'Can Opener', 'Bottle Opener',
		'Grater', 'Peeler', 'Whisk', 'Spatula', 'Ladle', 'Serving Spoon',


        -- Electronics & Gadgets
		'Smartphone', 'Tablet', 'Laptop', 'Smartwatch', 'Headphones', 'Earbuds', 'Bluetooth Speaker',
		'Portable Charger', 'USB Drive', 'External Hard Drive', 'Webcam', 'Microphone', 'Router',
		'Smart TV', 'Streaming Device', 'Gaming Console', 'Drone', 'Digital Camera', 'Action Camera',
		'E-Reader', 'GPS Device', 'Fitness Tracker', 'Smart Plug', 'Video Doorbell', 'Security Camera',


        -- Office & School Supplies
		'Notebook', 'Journal', 'Planner', 'Pen Set', 'Pencil Set', 'Highlighters', 'Markers',
		'Stapler', 'Staples', 'Paper Clips', 'Binder Clips', 'Sticky Notes', 'Printer Paper',
		'Envelopes', 'Folders', 'Binders', 'Calculator', 'Desk Organizer', 'Scissors', 'Tape Dispenser',
		'Whiteboard', 'Dry Erase Markers', 'Erasers', 'Pencil Sharpener', 'Correction Tape',


        -- Pet Supplies
		'Dog Food', 'Cat Food', 'Pet Treats', 'Dog Collar', 'Cat Collar', 'Dog Leash', 'Cat Harness',
		'Pet Bed', 'Dog Toy', 'Cat Toy', 'Litter Box', 'Cat Litter', 'Litter Scoop', 'Grooming Brush',
		'Pet Shampoo', 'Nail Clippers', 'Pet Carrier', 'Water Bowl', 'Food Bowl', 'Automatic Feeder',
		'Pet Fountain', 'Puppy Pads', 'Waste Bags', 'Flea & Tick Treatment',


        -- Sports & Outdoor
		'Yoga Mat', 'Dumbbell Set', 'Resistance Bands', 'Jump Rope', 'Water Bottle', 'Gym Bag',
		'Running Shoes', 'Hiking Boots', 'Camping Tent', 'Sleeping Bag', 'Backpacking Pack', 'Cooler',
		'Fishing Rod', 'Fishing Reel', 'Lure Set', 'Bicycle', 'Bicycle Helmet', 'Bike Lock',
		'Basketball', 'Football', 'Soccer Ball', 'Tennis Racket', 'Golf Clubs', 'Baseball Glove',
		'Ski Goggles', 'Snowboard', 'Skateboard', 'Roller Skates', 'Swim Goggles', 'Swim Cap',


        -- Baby & Kids Items
		'Baby Onesie', 'Baby Blanket', 'Diapers', 'Wipes', 'Baby Bottle Set', 'Pacifier', 'Teething Toy',
		'Stroller', 'Car Seat', 'High Chair', 'Crib Mattress', 'Baby Monitor', 'Baby Bath Tub',
		'Baby Carrier', 'Toy Blocks', 'Stuffed Animal', 'Kids Backpack', 'Lunchbox', 'Crayon Set',
		'Childrens Book', 'Puzzle', 'Board Game', 'Action Figure', 'Doll',


        -- Health & Personal Care
		'Toothbrush', 'Toothpaste', 'Mouthwash', 'Floss', 'Shampoo', 'Conditioner', 'Body Wash', 'Soap Bar',
		'Lotion', 'Sunscreen', 'Deodorant', 'Perfume', 'Cologne', 'Hair Dryer', 'Straightener',
		'Electric Razor', 'Shaving Cream', 'Band-Aids', 'First Aid Kit', 'Pain Reliever', 'Vitamins',
		'Hand Sanitizer', 'Facial Cleanser', 'Moisturizer', 'Serum', 'Makeup Kit', 'Nail Polish',


        -- Tools & Hardware
		'Hammer', 'Screwdriver Set', 'Pliers', 'Wrench Set', 'Tape Measure', 'Level', 'Drill',
		'Drill Bit Set', 'Utility Knife', 'Toolbox', 'Flashlight', 'Batteries', 'Extension Cord',
		'Power Strip', 'Work Gloves', 'Safety Goggles', 'Nail Assortment', 'Screw Assortment',

    	
        -- Clothing & Accessories
        'T-Shirt', 'Jeans', 'Dress Shirt', 'Sweater', 'Jacket', 'Socks', 'Scarf', 'Hat', 'Gloves',
        'Backpack', 'Handbag', 'Wallet', 'Belt', 'Sneakers', 'Boots', 'Sandals',

        -- Home Goods
        'Coffee Maker', 'Toaster', 'Blender', 'Vacuum Cleaner', 'Dish Soap', 'Laundry Detergent',
        'Pillow', 'Blanket', 'Sheet Set', 'Towel Set', 'Candle', 'Diffuser', 'Vase', 'Picture Frame',
        'Mug', 'Plate Set', 'Frying Pan', 'Mixing Bowl', 'Storage Container', 'Garden Hose', 'Shovel',
        'Desk Lamp', 'Bookshelf', 'Chair', 'Table', 'Rug', 'Curtains', 'Clock', 'Mirror', 'Plant Pot',

        -- Personal Care & Gifts
        'Soap Bar', 'Shampoo', 'Conditioner', 'Body Lotion', 'Perfume', 'Cologne', 'Lip Balm', 'Toothbrush Set',
        'Bath Bomb', 'Jewelry Box', 'Watch', 'Pen Set', 'Gift Card', 'Puzzle', 'Board Game',
        'Notebook', 'Sketchbook', 'Colored Pencils', 'Water Bottle', 'Travel Mug', 'Headphones',
        'Charger Cable', 'Phone Case', 'External Hard Drive', 'Webcam', 'Microphone',

	
        -- Clothing & Accessories
        'T-Shirt', 'Jeans', 'Dress Shirt', 'Sweater', 'Jacket', 'Socks', 'Scarf', 'Hat', 'Gloves',
        'Backpack', 'Handbag', 'Wallet', 'Belt', 'Sneakers', 'Boots', 'Sandals',

        -- Home Goods
        'Coffee Maker', 'Toaster', 'Blender', 'Vacuum Cleaner', 'Dish Soap', 'Laundry Detergent',
        'Pillow', 'Blanket', 'Sheet Set', 'Towel Set', 'Candle', 'Diffuser', 'Vase', 'Picture Frame',
        'Mug', 'Plate Set', 'Frying Pan', 'Mixing Bowl', 'Storage Container', 'Garden Hose', 'Shovel',
        'Desk Lamp', 'Bookshelf', 'Chair', 'Table', 'Rug', 'Curtains', 'Clock', 'Mirror', 'Plant Pot',

        -- Personal Care & Gifts
        'Soap Bar', 'Shampoo', 'Conditioner', 'Body Lotion', 'Perfume', 'Cologne', 'Lip Balm', 'Toothbrush Set',
        'Bath Bomb', 'Jewelry Box', 'Watch', 'Pen Set', 'Gift Card', 'Puzzle', 'Board Game',
        'Notebook', 'Sketchbook', 'Colored Pencils', 'Water Bottle', 'Travel Mug', 'Headphones',
        'Charger Cable', 'Phone Case', 'External Hard Drive', 'Webcam', 'Microphone',

        -- Plants & Outdoor
        'Fiddle Leaf Fig Plant', 'Snake Plant', 'Succulent Collection', 'Herb Garden Kit', 'Tomato Seeds',
        'Rose Bush', 'Garden Gnome', 'Bird Feeder', 'Outdoor Lantern', 'Camping Tent', 'Sleeping Bag',
        'Yoga Mat', 'Resistance Bands', 'Dumbbell Set'
    ])[FLOOR(RANDOM() * 480) + 1], -- Adjust the 80 based on the total number of items in your ARRAY

    -- actor: Generates a random "Actor Name"
    (ARRAY['Tom', 'Alice', 'Bob', 'Catherine', 'David', 'Eve', 'Frank', 'Grace', 'Henry', 'Ivy'])[FLOOR(RANDOM() * 10) + 1] || ' ' ||
    (ARRAY['Hanks', 'Smith', 'Jones', 'Williams', 'Brown', 'Davis', 'Miller', 'Wilson', 'Moore', 'Taylor'])[FLOOR(RANDOM() * 10) + 1],

    -- price: Random numeric value between 10.00 and 1000.00, formatted to 2 decimal places
    ROUND((RANDOM() * 990 + 10)::NUMERIC, 2),

    -- special: Randomly assigns 0, 1, or NULL (approximately 20% NULL, 40% 0, 40% 1)
    CASE FLOOR(RANDOM() * 5)
        WHEN 0 THEN NULL
        WHEN 1 THEN 0
        WHEN 2 THEN 1
        WHEN 3 THEN 0
        ELSE 1
    END::SMALLINT,

    -- common_prod_id: Random integer between 1000 and 9999
    FLOOR(RANDOM() * 9000 + 1000)::INTEGER
FROM generate_series(1, 100000) as gs(i); -- Use generate_series to create 1000 rows



SELECT
    prod_id,
    category,
    title,
    actor,
    price
FROM
    public.products_search
WHERE
    title_tsv @@ to_tsquery('english', 'plant');

SELECT
   count(*)
FROM
    public.products_search
WHERE
    title_tsv @@ to_tsquery('english', 'book');

-- SELECT p.prod_id, p.category, p.title, p.actor, p.price , p.title_tsv FROM public.products_search p WHERE p.title_tsv @@ to_tsquery('english', '')

-- select * from public.products_search;


-- insert into public.products_search (select * from public.products);

-- select count(*) from public.products_search ;

-- SELECT count(*) FROM public.products_search p WHERE p.title_tsv @@ to_tsquery('english', 'plants');
-- SELECT prod_id, category, title, actor, price, title_tsv FROM public.products_search WHERE title_tsv @@ to_tsquery('english', 'plants');

-- SELECT
--     prod_id,
--     title,
--     title_tsv
-- FROM
--     public.products_search
-- -- Where title like '%plant%';
-- ORDER BY
--     prod_id DESC
-- LIMIT 10;



-- SELECT 
--     deqs.last_execution_time AS [Time],	
--     dest.text AS [Query],
--     DB_NAME(dest.dbid) AS [Database]
-- FROM
--     sys.dm_exec_query_stats AS deqs
-- CROSS APPLY
--     sys.dm_exec_sql_text(deqs.sql_handle) AS dest
-- WHERE
--     dest.dbid = DB_ID('public') -- Optional: Filter for a specific database
-- ORDER BY
--     deqs.last_execution_time DESC;

