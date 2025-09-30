-- Tablo: clients (Müşteriler)
-- Notion'dan gelen müşteri verilerini saklar.
CREATE TABLE clients (
    id SERIAL PRIMARY KEY,
    notion_id TEXT UNIQUE,
    name TEXT NOT NULL,
    email TEXT,
    vat_no TEXT,
    status TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tablo: projects (Projeler)
-- Notion'dan gelen proje verilerini saklar (gelecekteki otomasyonlar için).
CREATE TABLE projects (
    id SERIAL PRIMARY KEY,
    notion_id TEXT UNIQUE,
    client_id INT REFERENCES clients(id),
    title TEXT NOT NULL,
    start_date DATE,
    end_date DATE,
    status TEXT
);

-- Tablo: transactions (Finansal İşlemler)
-- Google Sheets'ten gelen gelir/gider verilerini saklar.
CREATE TABLE transactions (
    id SERIAL PRIMARY KEY,
    sheets_row_id TEXT,
    type TEXT NOT NULL, -- 'income' (gelir) veya 'expense' (gider)
    transaction_date DATE,
    description TEXT,
    category TEXT,
    net_amount NUMERIC NOT NULL,
    vat_amount NUMERIC,
    gross_amount NUMERIC,
    client_id INT REFERENCES clients(id) ON DELETE SET NULL,
    project_id INT REFERENCES projects(id) ON DELETE SET NULL
);