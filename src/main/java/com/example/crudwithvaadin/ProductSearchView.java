package com.example.crudwithvaadin;

import com.vaadin.flow.component.button.Button;
import com.vaadin.flow.component.grid.Grid;
import com.vaadin.flow.component.icon.VaadinIcon;
import com.vaadin.flow.component.orderedlayout.HorizontalLayout;
import com.vaadin.flow.component.orderedlayout.VerticalLayout;
import com.vaadin.flow.component.textfield.TextField;
import com.vaadin.flow.data.value.ValueChangeMode;
import com.vaadin.flow.router.Route;
import org.springframework.util.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import com.vaadin.flow.spring.annotation.SpringComponent;
import com.vaadin.flow.spring.annotation.UIScope;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;

import java.util.List;

/**
 * A new Vaadin view specifically for product text search.
 * This view allows users to input a search term and see matching products
 * from the 'products_search' table.
 * It is accessible at the "/products" route.
 */
@Route("search") // This makes the view accessible at http://localhost:8080/search
@SpringComponent // Make this a Spring component
@UIScope // Make this a UI-scoped component
public class ProductSearchView extends VerticalLayout {

    private static final Logger logger = LoggerFactory.getLogger(ProductSearchView.class);

    private final ProductSearchRepository productSearchRepo; // Inject the ProductSearchRepository
    private final JdbcTemplate jdbcTemplate; // Inject JdbcTemplate

    final Grid<ProductSearch> grid; // Grid to display ProductSearch entities

    final TextField searchFilter; // Text field for the search query

    private final Button searchButton; // Button to trigger the search
    private final Button generateDataButton; // Button to generate dummy data

    /**
     * Constructor for ProductSearchView, injecting the ProductSearchRepository and JdbcTemplate.
     * Spring automatically provides the instances.
     * @param productSearchRepo The repository for performing product searches.
     * @param jdbcTemplate The JdbcTemplate for executing raw SQL queries.
     */
    @Autowired // Use Autowired for constructor injection
    public ProductSearchView(ProductSearchRepository productSearchRepo, JdbcTemplate jdbcTemplate) {
        this.productSearchRepo = productSearchRepo;
        this.jdbcTemplate = jdbcTemplate; // Assign the injected JdbcTemplate

        this.grid = new Grid<>(ProductSearch.class); // Initialize the Grid with ProductSearch type
        this.searchFilter = new TextField();
        this.searchButton = new Button("Search", VaadinIcon.SEARCH.create());
        this.generateDataButton = new Button("Generate Dummy Data", VaadinIcon.DATABASE.create()); // Initialize new button

        // Configure search filter
        searchFilter.setPlaceholder("Search by title...");
        searchFilter.setClearButtonVisible(true);
        searchFilter.setPlaceholder("Enter search term (e.g., 'book', 'shoes & shirt')");
        searchFilter.setClearButtonVisible(true);
        searchFilter.setWidth("400px");
        searchFilter.setValueChangeMode(ValueChangeMode.LAZY); // Search on value change with a slight delay

        // Layout components
        HorizontalLayout toolbar = new HorizontalLayout(searchFilter, searchButton); // Add new button to toolbar
        add(toolbar, grid); // Add controls and grid to the main VerticalLayout

        // Hook logic to components

        // Trigger search when user presses Enter in the search field or on value change (lazy)
        searchFilter.addValueChangeListener(e -> listProducts(e.getValue()));
        // Trigger search when the search button is clicked
        searchButton.addClickListener(e -> listProducts(searchFilter.getValue()));

        // // Hook logic for the generate data button
        // generateDataButton.addClickListener(e -> generateData());

        // Configure Grid columns to include title_tsv
        grid.setColumns("prodId", "category", "title", "actor", "price", "title_tsv"); // Display these columns

        // Removed: Initial call to listProducts(null)
        // The grid will now start empty, and data will only load when a search is performed.
    }

    /**
     * Lists products based on the provided filter text.
     * If filterText is empty, it fetches all products.
     * Otherwise, it performs a full-text search using the ProductSearchRepository.
     * @param filterText The text to search for in product titles.
     */
    void listProducts(String filterText) {
        logger.info("Initiating product list refresh with filter: [{}]", filterText);
        List<ProductSearch> products;

        if (StringUtils.hasText(filterText)) {
            // Log the count of matching records for diagnostic purposes
            Long count = productSearchRepo.countText(filterText);
            logger.info("Database reports [{}] records for search term: [{}]", count, filterText);

            // Perform text search using the repository's custom query (now using plainto_tsquery).
            products = productSearchRepo.searchText(filterText);
            logger.info("Found {} products returned by searchText method for search term: [{}]", products.size(), filterText);
        } else {
            // If no filter text, fetch all products. Be cautious with large datasets here.
            // For an initial empty grid, this block will not be reached unless an empty
            // search is explicitly performed.
            products = productSearchRepo.findAll();
            logger.info("Found {} total products (no filter).", products.size());
        }

        // Log the actual data being sent to the grid
        products.forEach(product -> logger.debug("Product fetched: {}", product));

        grid.setItems(products);
        logger.info("Grid updated with {} items.", products.size());
    }

    /**
     * Triggers the generation of dummy data in the database.
     * Displays notifications to the user about the process.
     * Runs asynchronously to avoid blocking the UI.
     */
    // private void generateData() {
    //     Notification.show("Generating 100,000 dummy records. This may take a while...", 5000, Notification.Position.MIDDLE)
    //             .addThemeVariants(NotificationVariant.LUMO_PRIMARY);
    //     logger.info("Starting dummy data generation...");

    //     // Execute data generation asynchronously to avoid blocking the UI
    //     CompletableFuture.runAsync(() -> {
    //         try {
    //             // Pass the injected JdbcTemplate to the repository method
    //             productSearchRepo.generateDummyData(jdbcTemplate);
    //             getUI().ifPresent(ui -> ui.access(() -> {
    //                 Notification.show("Dummy data generation completed successfully!", 3000, Notification.Position.MIDDLE)
    //                         .addThemeVariants(NotificationVariant.LUMO_SUCCESS);
    //                 logger.info("Dummy data generation completed.");
    //                 listProducts(searchFilter.getValue()); // Refresh the grid after data generation
    //             }));
    //         } catch (Exception e) {
    //             logger.error("Error during dummy data generation", e);
    //             getUI().ifPresent(ui -> ui.access(() -> {
    //                 Notification.show("Error generating dummy data: " + e.getMessage(), 5000, Notification.Position.MIDDLE)
    //                         .addThemeVariants(NotificationVariant.LUMO_ERROR);
    //             }));
    //         }
    //     });
    // }
}