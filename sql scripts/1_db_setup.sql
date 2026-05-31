-- ============================================================================
-- MODULE 1: DATABASE CREATION & SCHEMA ARCHITECTURE
-- ============================================================================

-- Ensure execution context is master to drop/create databases safely
USE master;

-- Drop database if it exists to allow clean environment redeployments
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_database WHERE datname = 'SecureCommerceDB') THEN
        PERFORM pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = 'SecureCommerceDB';
        EXECUTE 'DROP DATABASE "SecureCommerceDB"';
    END IF;
END $$;

-- Create the central project database
CREATE DATABASE "SecureCommerceDB";

-- [CRITICAL]: Switch your pgAdmin Query Tool connection to "SecureCommerceDB" before running the code below.
-- ============================================================================

-- Create general public catalog table (Standard sensitivity)
CREATE TABLE public.products (
    product_id SERIAL CONSTRAINT pk_products PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    unit_price NUMERIC(10,2) NOT NULL
);

-- Create initial customer table holding clear-text PII & Financial Data for staging
CREATE TABLE public.customers (
    customer_id SERIAL CONSTRAINT pk_customers PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20) NULL,
    national_id CHAR(11) NOT NULL,          -- Critical PII (To be encrypted)
    credit_card_number VARCHAR(16) NOT NULL, -- PCI-DSS Scope (To be encrypted)
    monthly_income NUMERIC(10,2) NOT NULL   -- Sensitive Financial Data
);

-- ============================================================================
-- DATA SEEDING (Populating the database with realistic enterprise data)
-- ============================================================================
INSERT INTO public.products (product_name, category, unit_price) VALUES 
('Smartphone X', 'Electronics', 999.99),
('Running Shoes', 'Apparel', 89.50),
('Wireless Headphones', 'Electronics', 149.99);

INSERT INTO public.customers (full_name, email, phone_number, national_id, credit_card_number, monthly_income) VALUES 
('Eda Nur Arslan', 'eda@arslan.com', '+905551234567', '12345678901', '4321876543210987', 4500.00),
('John Doe', 'john.doe@securemail.com', '+15559876543', '98765432101', '5555666677778888', 3200.00);

-- ============================================================================
-- CORE VERIFICATION QUERIES
-- ============================================================================
SELECT * FROM public.products;
SELECT * FROM public.customers;
