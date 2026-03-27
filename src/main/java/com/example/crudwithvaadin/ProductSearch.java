package com.example.crudwithvaadin;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.math.BigDecimal;

/**
 * JPA Entity for the products_search table.
 * This entity maps the columns from the PostgreSQL table to Java fields.
 */
@Entity
@Table(name = "products_search")
public class ProductSearch {

    @Id
    @Column(name = "prod_id")
    private Integer prodId;

    @Column(name = "category")
    private Integer category;

    @Column(name = "title")
    private String title;

    @Column(name = "actor")
    private String actor;

    @Column(name = "price")
    private BigDecimal price;

    @Column(name= "title_tsv")
    private String title_tsv;

    /**
     * Default constructor required by JPA.
     */
    public ProductSearch() {
    }

    /**
     * Constructor for creating ProductSearch objects.
     * @param prodId The product ID.
     * @param category The product category.
     * @param title The product title.
     * @param actor The actor/author/brand of the product.
     * @param price The price of the product.
     * @param title_tsv The text search vector representation of the title (managed by DB trigger).
     */
    public ProductSearch(Integer prodId, Integer category, String title, String actor, BigDecimal price, String title_tsv) {
        this.prodId = prodId;
        this.category = category;
        this.title = title;
        this.actor = actor;
        this.price = price;
        this.title_tsv = title_tsv;
    }

    // --- Getters for all fields ---

    public Integer getProdId() {
        return prodId;
    }

    public Integer getCategory() {
        return category;
    }

    public String getTitle() {
        return title;
    }

    public String getTitle_tsv() {
        return title_tsv;
    }

    public String getActor() {
        return actor;
    }

    public BigDecimal getPrice() {
        return price;
    }

    // --- Setters (optional, but good practice if you plan to update entities) ---

    public void setProdId(Integer prodId) {
        this.prodId = prodId;
    }

    public void setCategory(Integer category) {
        this.category = category;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public void setTitle_tsv(String title_tsv) {
        this.title_tsv = title_tsv;
    }

    public void setActor(String actor) {
        this.actor = actor;
    }

    public void setPrice(BigDecimal price) {
        this.price = price;
    }

    @Override
    public String toString() {
        return "ProductSearch{" +
               "prodId=" + prodId +
               ", category=" + category +
               ", title='" + title + '\'' +
               ", actor='" + actor + '\'' +
               ", price=" + price +
               ", title_tsv='" + title_tsv + '\'' +
               '}';
    }
}