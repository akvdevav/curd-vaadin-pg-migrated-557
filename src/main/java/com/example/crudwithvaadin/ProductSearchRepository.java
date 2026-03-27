package com.example.crudwithvaadin;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;

/**
 * Spring Data JPA Repository for the ProductSearch entity.
 * This repository provides methods for interacting with the products_search table.
 */
public interface ProductSearchRepository extends JpaRepository<ProductSearch, Integer> {

    /**
     * Performs a full-text search on the 'title_tsv' column using PostgreSQL's
     * text search capabilities.
     *
     * @param searchTerm The search term provided by the user. This will be converted
     * to a tsquery.
     * @return A list of ProductSearch entities matching the search term.
     *
     * The `to_tsquery` function converts the `searchTerm` into a valid tsquery.
     * The `@@` operator checks if the `title_tsv` (tsvector) matches the `to_tsquery`.
     * Using `ts_lexize` with `simple` dictionary and `plainto_tsquery` can be alternatives
     * for more flexible or simpler search term processing if 'book' format is too strict.
     * For this example, 'english' dictionary is used as in your SQL.
     */
    @Query(value = "SELECT p.prod_id, p.category, p.title, p.actor, p.price, title_tsv " +
                   "FROM public.products_search p " +
                   "WHERE p.title_tsv @@ to_tsquery('english', :searchTerm)",
           nativeQuery = true) // Indicates that this is a native SQL query
    List<ProductSearch> searchText(@Param("searchTerm") String searchTerm;


     @Query(value = "SELECT count(*) FROM public.products_search p WHERE p.title_tsv @@ to_tsquery('english', :searchTerm)",
           nativeQuery = true)
    Long countText(@Param("searchTerm") String searchTerm;


    // @Modifying
    // @Transactional
    // default void generateDummyData(JdbcTemplate jdbcTemplate) { // Accept JdbcTemplate as parameter or autowire it
    //     try {
    //         // Load the SQL script from classpath
    //         ClassPathResource resource = new ClassPathResource("sql/generate_dummy_products.sql");
    //         String sql;
    //         try (Reader reader = new InputStreamReader(resource.getInputStream(), StandardCharsets.UTF_8)) {
    //             sql = FileCopyUtils.copyToString(reader);
    //         }
    //         // Execute the loaded SQL
    //         jdbcTemplate.execute(sql);
    //     } catch (IOException e) {
    //         throw new RuntimeException("Failed to load or execute SQL script for dummy data generation", e);
    //     }
    // }
}