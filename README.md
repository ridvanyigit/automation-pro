<p align="center">
  <a href="#english-version--englische-version">🇬🇧 English</a> • 
  <a href="#deutsche-version--german-version">🇩🇪 Deutsch</a> • 
  <a href="#türkçe-versiyon--turkish-version">🇹🇷 Türkçe</a>
</p>

<h1 align="center">Self-Hosted Business Automation & Analytics Hub</h1>
<h3 align="center">for Freelancers, Einzelunternehmer & Şahıs Şirketleri</h3>


<p align="center">
  This repository contains a complete guide to building a robust, self-hosted automation and analytics suite for solo business operations. Choose your preferred language below to get started.
</p>
<p align="center">
  Dieses Repository enthält eine vollständige Anleitung zum Aufbau einer robusten, selbstgehosteten Automatisierungs- und Analyse-Suite für den Solo-Geschäftsbetrieb. Wähle unten deine bevorzugte Sprache, um zu beginnen.
</p>
<p align="center">
  Bu proje, solo girişimcilik faaliyetleri için sağlam, kendi sunucusunda barındırılan bir otomasyon ve analiz altyapısı kurmaya yönelik eksiksiz bir rehber içerir. Başlamak için aşağıdan tercih ettiğiniz dili seçin.
</p>

<br>

<details id="english-version--englische-version">
<summary><h2>🇬🇧 English Version / Englische Version</h2></summary>

<h1 align="center">Self-Hosted Business Automation & Analytics Hub for Freelancers</h1>

<p align="center">
  A robust, self-hosted automation and analytics suite designed to streamline the core operations of a solo business. This system integrates user-friendly tools (Notion, Google Sheets) with a powerful, centralized PostgreSQL database, orchestrated by n8n for automation and visualized through Metabase for business intelligence.
</p>

<p align="center">
  This project stands as a testament to building a resilient, scalable, and private digital infrastructure without relying on expensive, multi-platform SaaS subscriptions.
</p>

---

<div align="center">
  <a href="#-system-architecture"><strong>🏗️ Architecture</strong></a> | 
  <a href="#-prerequisites"><strong>✅ Prerequisites</strong></a> | 
  <a href="#-core-setup"><strong>⚙️ Core Setup</strong></a> | 
  <a href="#-workflows-data-automation"><strong>🚀 Workflows</strong></a> |
  <a href="#-phase-3-data-analysis--visualization"><strong>📊 Analytics</strong></a> |
  <a href="#-system-operation-guide"><strong> Keping it Running</strong></a> |
  <a href="#-troubleshooting-our-journey"><strong>🛠️ Troubleshooting</strong></a> | 
  <a href="#-maintenance--backup-strategies"><strong>💾 Maintenance & Backup</strong></a>
</div>

---

## 🏗️ System Architecture

| Layer | Tool | Responsibility | Data Type |
| :--- | :--- | :--- | :--- |
| **Interface Layer** | **Notion** | Client & Project Management (CRM/PM) | Structured Text |
| (Daily Use) | **Google Sheets** | Financial Ledgers (Income/Expenses) | Structured Financial Data |
| | **Google Drive** | Document & Backup Archive | Unstructured Files |
| **Automation Layer** | **n8n** | The "Digital Glue". Listens for triggers, syncs data, and performs scheduled tasks like backups. | Transient JSON Data |
| (The Engine) | (via Docker) | | |
| **Analytics Layer** | **Metabase** | The "Brain". Connects to the database to visualize data, ask questions, and create dashboards. | Visual Charts & Dashboards |
| (The Insights) | (via Docker) | | |
| **Data Layer** | **PostgreSQL** | The "Single Source of Truth". Centralized, long-term storage for all structured data. | Relational SQL Data |
| (The Foundation) | (via Docker) | | |

---

## ✅ Prerequisites

*   **Docker Desktop:** To run the containerized applications. [Download Docker](https://www.docker.com/products/docker-desktop/).
*   **A Notion Account:** With a workspace to create databases.
*   **A Google Account:** For Google Drive and Google Sheets access.

---

## ⚙️ Core Setup

This section covers the one-time setup of the foundational infrastructure.

### 1. Backend Setup: PostgreSQL & pgAdmin

Open your terminal and run the following commands. Replace `your-secure-password` with a strong password.

```bash
# Launch the PostgreSQL database container
docker run --name business-db -e POSTGRES_PASSWORD=your-secure-password -p 5432:5432 -d postgres

# Launch the pgAdmin web interface
docker run --name business-pgadmin -p 8080:80 -e "PGADMIN_DEFAULT_EMAIL=your-email@example.com" -e "PGADMIN_DEFAULT_PASSWORD=your-pgadmin-password" -d dpage/pgadmin4
```

### 2. Automation & Analytics Engine Setup

Launch the n8n and Metabase containers.

```bash
# Launch the n8n automation engine container
docker run --name n8n -p 5678:5678 -d n8nio/n8n

# Launch the Metabase analytics engine container
docker run --name metabase -p 3000:3000 -d metabase/metabase
```

### 3. Docker Networking (Crucial Step!)

To allow all containers to communicate reliably by name, we must create a dedicated network and connect them all to it.

```bash
# 1. Stop all running containers to safely reconfigure networking
docker stop n8n metabase business-pgadmin business-db

# 2. Create a new Docker network
docker network create my-business-net

# 3. Restart the containers and connect them to the new network
docker start business-db && docker network connect my-business-net business-db
docker start business-pgadmin && docker network connect my-business-net business-pgadmin
docker start n8n && docker network connect my-business-net n8n
docker start metabase && docker network connect my-business-net metabase
```
> **Why is this necessary?** Without a shared network, containers cannot resolve each other's hostnames (e.g., `n8n` cannot find `business-db`), resulting in connection errors. This setup ensures stable internal DNS.

### 4. Database Schema Initialization

1.  Navigate to `http://localhost:8080` to access pgAdmin.
2.  Add a new server connection:
    *   **Name:** `Local Business DB`
    *   **Host:** `business-db`
    *   **Port:** `5432`
    *   **Username:** `postgres`
    *   **Password:** Your chosen PostgreSQL password.
3.  Open the **Query Tool** for the `postgres` database and execute the following SQL code:

```sql
-- Main tables for core business entities
CREATE TABLE clients (
    id SERIAL PRIMARY KEY,
    notion_id TEXT UNIQUE,
    name TEXT NOT NULL,
    email TEXT,
    vat_no TEXT,
    status TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE projects (
    id SERIAL PRIMARY KEY,
    notion_id TEXT UNIQUE,
    client_id INT REFERENCES clients(id),
    title TEXT NOT NULL,
    start_date DATE,
    end_date DATE,
    status TEXT
);

CREATE TABLE transactions (
    id SERIAL PRIMARY KEY,
    sheets_row_id TEXT,
    type TEXT NOT NULL,
    transaction_date DATE,
    description TEXT,
    category TEXT,
    net_amount NUMERIC NOT NULL,
    vat_amount NUMERIC,
    gross_amount NUMERIC,
    client_id INT REFERENCES clients(id) ON DELETE SET NULL,
    project_id INT REFERENCES projects(id) ON DELETE SET NULL
);
```

### 5. API Credentials & Permissions Setup
Follow the detailed steps in the [Troubleshooting section](#-troubleshooting-our-journey) or official docs to create API credentials for **Notion** and **Google Cloud Platform (for Drive & Sheets)**. Key steps include enabling the APIs, creating an OAuth client ID, and adding yourself as a test user in GCP to avoid authentication errors.

---

## 🚀 Workflows: Data Automation

These are the "set it and forget it" automations that populate your database and protect your data.

### Workflow 1: Automated Client Onboarding
*   **Trigger:** New row in a Notion `Clients` Database.
*   **Actions:** Create a Google Drive folder for the client, then insert a new record into the PostgreSQL `clients` table.

### Workflow 2: Automated Financial Logging
*   **Trigger:** New row in a Google Sheets `Income` ledger.
*   **Action:** An **IF node** first checks if the date column is empty to filter out "ghost rows." If data is present, it inserts a new record into the PostgreSQL `transactions` table.

### Workflow 3: Automated Monthly Notion Backup
*   **Trigger:** A **`Schedule`** node set to run on the 1st of every month at 3 AM.
*   **Actions (Parallel Branches):**
    1.  **Branch 1 (Clients):** A `Notion` node (Get Many) fetches all client data -> A `Convert to file` node turns it into a CSV -> A `Google Drive` node uploads the file with a dynamic name (`Clients_Backup_{{$now.toFormat('yyyy-MM-dd')}}.csv`) to a dedicated backup folder.
    2.  **Branches 2 & 3:** The same process is repeated for the `Projects` and `Tasks` databases.

---

## 📊 Phase 3: Data Analysis & Visualization
With data flowing into your database, it's time to create insights using Metabase.

### 1. Connect Metabase to Your Database
1.  Navigate to `http://localhost:3000` and complete the Metabase setup wizard.
2.  If you skipped the database connection, go to **Admin settings (⚙️) -> Databases -> Add database**.
3.  Enter the following connection details:
    *   **Database type:** `PostgreSQL`
    *   **Host:** `business-db`
    *   **Port:** `5432`
    *   **Database name:** `postgres`
    *   **Username:** `postgres`
    *   **Password:** Your PostgreSQL password.
    *   **SSL:** `Disabled`.
4.  Save the connection. Metabase will now scan your tables.

### 2. Create Your First Insight (A "Question")
Let's build a "Monthly Net Revenue" chart.
1.  Click **`+ New` -> `Question`**.
2.  Select **`Raw Data` -> Your Database -> `Transactions`**.
3.  In the editor:
    *   Click **`Summarize`** and choose **`Sum of` -> `Net Amount`**.
    *   Click the **`Group by`** section below it and choose **`Transaction Date` -> `by Month`**.
4.  Click **`Visualize`** to see your chart.
5.  **`Save`** the question, giving it a clear name like "Monthly Net Revenue Chart."

### 3. Build Your Command Center (A "Dashboard")
1.  Click **`+ New` -> `Dashboard`**.
2.  Give your dashboard a name, like "Main Business Overview."
3.  Click the **`+`** icon on the dashboard to add your saved "Monthly Net Revenue Chart."
4.  Resize and arrange your charts as needed, then **`Save`** the dashboard.

---

## ⚙️ System Operation Guide

### Conditions for Flawless Operation
The entire system runs continuously and autonomously under two conditions:
1.  **The Host Machine is Running:** Your computer must be powered on.
2.  **The Docker Desktop Application is Running:** The Docker engine must be active. You can verify this by checking for the Docker whale icon (🐳) in your system's menu bar.

### Scenarios Causing a System Stop
The system will stop functioning if:
*   The host machine is shut down or restarted.
*   You manually quit the Docker Desktop application.
*   A container is manually stopped via the terminal (e.g., `docker stop n8n`).

### System Restart Protocol
If you find that your automations are not running or Metabase is inaccessible, follow this protocol:

**1. Verify Docker is Running:** Ensure the Docker Desktop application is open and running. This solves 90% of issues. Docker typically restarts previously running containers automatically.

**2. Check Container Status:** Open your terminal and run the following command to see a list of all containers and their current status:
```bash
docker ps -a
```
Look at the `STATUS` column. Any container that does not say `Up` needs to be started.

**3. Restart Stopped Containers:** For any container that is not running, use the `docker start` command with its name.
```bash
# Example: If the n8n container is stopped
docker start n8n

# Start all core containers if needed
docker start business-db business-pgadmin n8n metabase
```
Once the containers are `Up`, the system will resume normal operation.

---

## 🛠️ Troubleshooting: Our Journey & Solutions
*   **Error:** `Couldn’t connect...` & `ping: bad address 'business-db'`.
    *   **Cause:** Containers were not on a shared Docker network.
    *   **Solution:** Creating a dedicated network (`my-business-net`) and connecting all containers to it.

*   **Error:** `Error 403: access_denied` with Google authentication.
    *   **Cause:** The authenticating user was not listed as a "Test user" in the Google Cloud project's OAuth screen.
    *   **Solution:** Add your email to the **Test users** list in the GCP Console.

*   **Error:** `Google Drive/Sheets API has not been used... or it is disabled.`
    *   **Cause:** The specific API was not enabled for the GCP project.
    *   **Solution:** In the GCP Console's **Library**, find and **ENABLE** the required API.

*   **Issue:** Workflow fails on empty Google Sheet rows.
    *   **Cause:** The trigger reads rows with formulas as valid data, sending empty values that cause errors.
    *   **Solution:** Adding an **IF node** after the trigger to filter out rows where a key column (like the date) is empty.

*   **Error:** `violates foreign key constraint...`.
    *   **Cause:** The database correctly rejects linking a transaction to a non-existent project/client. n8n sent `0` by default for empty fields.
    *   **Solution:** In the PostgreSQL node, explicitly do not map the foreign key fields (`client_id`, `project_id`), or set their value to the expression `{{ null }}` to signify an intentionally empty value.

---

## 💾 Maintenance & Backup Strategies

A self-hosted system requires responsible management. These two strategies ensure your data remains safe and recoverable.

### 1. Automated Monthly Notion Backup (via n8n)
This workflow, detailed in the [Workflows section](#-workflows-data-automation), automatically creates a CSV backup of your primary Notion databases (`Clients`, `Projects`, `Tasks`) and saves them to a Google Drive folder on the first day of every month. This protects your primary workspace data.

### 2. Manual Monthly PostgreSQL Backup
This process creates a full, technical snapshot of your entire database.

**On the first day of each month, run these commands in your terminal:**
```bash
# Navigate to your Desktop
cd ~/Desktop

# Execute pg_dumpall inside the container to create a full backup
docker exec business-db pg_dumpall -U postgres > backup_$(date +%Y-%m-%d).sql
```
After running, manually drag the generated `.sql` file to a secure cloud location like Google Drive.

---

## ✍️ Author
This system was designed, built, and documented by **[Your Name Here]**.
*   **GitHub:** [ridvanyigit](https://github.com/kullanici-adiniz)
*   **LinkedIn:** [Ridvan Yigit](https://linkedin.com/in/profiliniz)
*   **Website:** [www.ridvanyigit.com](https://www.ridvanyigit.com/)

</details>

<br>

<details id="deutsche-version--german-version">
<summary><h2>🇩🇪 Deutsche Version / German Version</h2></summary>

<h1 align="center">Self-Hosted Business Automation & Analytics Hub für Einzelunternehmer</h1>

<p align="center">
  Eine robuste, selbstgehostete Automatisierungs- und Analyse-Suite zur Optimierung der Kernprozesse eines Einzelunternehmens. Dieses System integriert benutzerfreundliche Tools (Notion, Google Sheets) mit einer leistungsstarken, zentralen PostgreSQL-Datenbank, orchestriert durch n8n für die Automatisierung und visualisiert durch Metabase für Business Intelligence.
</p>

---

<div align="center">
  <a href="#-systemarchitektur-1"><strong>🏗️ Systemarchitektur</strong></a> | 
  <a href="#-voraussetzungen-1"><strong>✅ Voraussetzungen</strong></a> | 
  <a href="#-grundlegende-einrichtung-1"><strong>⚙️ Grundlegende Einrichtung</strong></a> | 
  <a href="#-workflows-datenautomatisierung"><strong>🚀 Workflows</strong></a> |
  <a href="#-phase-3-datenanalyse--visualisierung-1"><strong>📊 Analyse</strong></a> |
  <a href="#-systembetriebs-leitfaden-1"><strong> Systembetrieb</strong></a> |
  <a href="#-fehlerbehebung-unsere-erfahrungen-1"><strong>🛠️ Fehlerbehebung</strong></a> | 
  <a href="#-wartungs--backup-strategien"><strong>💾 Wartung & Backup</strong></a>
</div>

---

## 🏗️ Systemarchitektur
| Schicht | Tool | Zuständigkeit | Datentyp |
| :--- | :--- | :--- | :--- |
| **Interface-Schicht** | **Notion** | Kunden- & Projektverwaltung (CRM/PM) | Strukturierter Text |
| (Tägl. Nutzung) | **Google Sheets** | Finanzaufzeichnungen (Einnahmen/Ausgaben) | Strukturierte Finanzdaten |
| | **Google Drive** | Dokumenten- & Backup-Archiv | Unstrukturierte Dateien |
| **Automatisierungs-Schicht**| **n8n** | Der "digitale Klebstoff". Synchronisiert Daten und führt geplante Backups aus. | Transiente JSON-Daten |
| (Die Engine) | (via Docker) | | |
| **Analyse-Schicht** | **Metabase** | Das "Gehirn". Verbindet sich mit der DB, um Daten zu visualisieren und Dashboards zu erstellen. | Visuelle Diagramme & Dashboards |
| (Die Einblicke) | (via Docker) | | |
| **Daten-Schicht** | **PostgreSQL** | Die "zentrale Datenquelle". Zentraler, langfristiger Speicher für alle strukturierten Daten. | Relationale SQL-Daten |
| (Die Grundlage) | (via Docker) | | |

---

## ✅ Voraussetzungen
*   **Docker Desktop:** [Docker herunterladen](https://www.docker.com/products/docker-desktop/).
*   **Ein Notion-Account**.
*   **Ein Google-Account**.

---

## ⚙️ Grundlegende Einrichtung

### 1. Backend-Setup: PostgreSQL & pgAdmin
Ersetze `dein-sicheres-passwort` durch ein starkes Passwort.
```bash
docker run --name business-db -e POSTGRES_PASSWORD=dein-sicheres-passwort -p 5432:5432 -d postgres
docker run --name business-pgadmin -p 8080:80 -e "PGADMIN_DEFAULT_EMAIL=deine-email@example.com" -e "PGADMIN_DEFAULT_PASSWORD=dein-pgadmin-passwort" -d dpage/pgadmin4
```

### 2. Automatisierungs- & Analyse-Engine-Setup
```bash
docker run --name n8n -p 5678:5678 -d n8nio/n8n
docker run --name metabase -p 3000:3000 -d metabase/metabase
```

### 3. Docker-Netzwerk (Entscheidender Schritt!)
```bash
docker stop n8n metabase business-pgadmin business-db
docker network create my-business-net
docker start business-db && docker network connect my-business-net business-db
docker start business-pgadmin && docker network connect my-business-net business-pgadmin
docker start n8n && docker network connect my-business-net n8n
docker start metabase && docker network connect my-business-net metabase
```

### 4. Initialisierung des Datenbankschemas
1.  Gehe zu `http://localhost:8080` (pgAdmin).
2.  Füge eine neue Serververbindung hinzu: **Name:** `Lokale Geschäfts-DB`, **Host:** `business-db`, **Port:** `5432`, **Username:** `postgres`, **Password:** dein PostgreSQL-Passwort.
3.  Öffne das **Query Tool** für die `postgres`-DB und führe diesen SQL-Code aus:
```sql
CREATE TABLE clients (...);
CREATE TABLE projects (...);
CREATE TABLE transactions (...);
-- (Der vollständige SQL-Code befindet sich in der englischen Sektion)
```

### 5. API-Zugangsdaten & Berechtigungen
Folge den detaillierten Schritten im [Troubleshooting-Abschnitt](#-fehlerbehebung-unsere-erfahrungen-1) oder den offiziellen Dokumentationen, um API-Zugangsdaten für **Notion** und die **Google Cloud Platform** zu erstellen. Wichtige Schritte sind die Aktivierung der APIs, das Erstellen einer OAuth Client ID und das Hinzufügen deiner E-Mail als Testbenutzer in GCP.

---

## 🚀 Workflows: Datenautomatisierung

### Workflow 1: Automatisiertes Kunden-Onboarding
*   **Auslöser:** Neue Zeile in einer Notion `Kunden`-Datenbank.
*   **Aktionen:** Erstellt einen Google Drive-Ordner und fügt einen neuen Datensatz in die PostgreSQL `clients`-Tabelle ein.

### Workflow 2: Automatisierte Finanzbuchhaltung
*   **Auslöser:** Neue Zeile in einem Google Sheet `Einnahmen`.
*   **Aktion:** Ein **IF-Node** prüft zuerst, ob die Datumsspalte leer ist. Wenn Daten vorhanden sind, fügt er einen neuen Datensatz in die `transactions`-Tabelle ein.

### Workflow 3: Automatisches Monatliches Notion-Backup
*   **Auslöser:** Ein **`Schedule`**-Node, der am 1. jedes Monats um 3 Uhr morgens läuft.
*   **Aktionen (Parallele Zweige):**
    1.  **Zweig 1 (Kunden):** Ein `Notion`-Node (`Viele abrufen`) holt alle Kundendaten -> Ein `In Datei umwandeln`-Node erstellt ein CSV -> Ein `Google Drive`-Node lädt die Datei mit dynamischem Namen (`Kunden_Backup_{{$now.toFormat('yyyy-MM-dd')}}.csv`) hoch.
    2.  **Zweige 2 & 3:** Derselbe Prozess wird für die `Projekte`- und `Aufgaben`-Datenbanken wiederholt.

---

## 📊 Phase 3: Datenanalyse & Visualisierung
Mit Metabase verwandeln wir Daten in Einblicke.

### 1. Metabase mit deiner Datenbank verbinden
1.  Gehe zu `http://localhost:3000`.
2.  Gehe zu **Admin-Einstellungen (⚙️) -> Datenbanken -> Datenbank hinzufügen**.
3.  Gib folgende Verbindungsdetails ein:
    *   **Datenbanktyp:** `PostgreSQL`
    *   **Host:** `business-db`
    *   **Passwort:** dein PostgreSQL-Passwort.
    *   ... (restliche Details wie oben)

### 2. Deinen ersten Einblick erstellen (Eine "Frage")
1.  Klicke auf **`+ Neu` -> `Frage`**.
2.  Wähle **`Rohdaten` -> Deine Datenbank -> `Transactions`**.
3.  Im Editor: **`Zusammenfassen`** -> **`Summe von` -> `Net Amount`**. Dann **`Gruppieren nach`** -> **`Transaction Date` -> `nach Monat`**.
4.  Klicke auf **`Visualisieren`** und **`Speichere`** die Frage als "Monatlicher Nettoumsatz".

### 3. Dein Kommandozentrum erstellen (Ein "Dashboard")
1.  Klicke auf **`+ Neu` -> `Dashboard`**.
2.  Gib dem Dashboard einen Namen, z. B. "Hauptgeschäftsübersicht".
3.  Klicke auf das **`+`**-Symbol, um deine gespeicherte Frage hinzuzufügen und **`Speichere`** das Dashboard.

---

## ⚙️ Systembetriebs-Leitfaden

### Bedingungen für einen reibungslosen Betrieb
1.  **Der Host-Rechner läuft.**
2.  **Die Docker Desktop Anwendung läuft** (sichtbar durch das Wal-Symbol 🐳).

### Szenarien, die zu einem Systemstopp führen
*   Der Host-Rechner wird heruntergefahren/neu gestartet.
*   Du beendest die Docker Desktop Anwendung.
*   Ein Container wird manuell gestoppt.

### System-Neustart-Protokoll
**1. Docker-Status prüfen:** Stelle sicher, dass Docker Desktop läuft.
**2. Container-Status prüfen:** Führe `docker ps -a` im Terminal aus.
**3. Gestoppte Container neu starten:**
```bash
docker start business-db business-pgadmin n8n metabase
```

---

## 🛠️ Fehlerbehebung: Unsere Erfahrungen & Lösungen
*   **Fehler:** `Couldn’t connect...` & `ping: bad address 'business-db'`.
    *   **Lösung:** Erstellen eines dedizierten Docker-Netzwerks (`my-business-net`) und Verbinden aller Container.

*   **Fehler:** `Error 403: access_denied` bei Google.
    *   **Lösung:** Füge deine E-Mail zur **Test users**-Liste in der GCP Console hinzu.

*   **Fehler:** `Google... API has not been used...`.
    *   **Lösung:** In der **Library** der GCP Console die benötigte API **AKTIVIEREN**.

*   **Problem:** Workflow schlägt bei leeren Google Sheet-Zeilen fehl.
    *   **Lösung:** Hinzufügen eines **IF-Nodes**, der prüft, ob eine Schlüsselspalte leer ist.

*   **Fehler:** `violates foreign key constraint...`.
    *   **Lösung:** Im PostgreSQL-Node die Fremdschlüsselfelder auf den Ausdruck `{{ null }}` setzen.

---

## 💾 Wartungs- & Backup-Strategien

### 1. Automatisches Monatliches Notion-Backup (via n8n)
Dieser Workflow, detailliert im [Workflows-Abschnitt](#-workflows-datenautomatisierung), sichert monatlich automatisch Ihre primären Notion-Datenbanken als CSV-Dateien in Google Drive.

### 2. Manuelles Monatliches PostgreSQL-Backup
```bash
cd ~/Desktop
docker exec business-db pg_dumpall -U postgres > backup_$(date +%Y-%m-%d).sql
```
Ziehe die erstellte `.sql`-Datei manuell an einen sicheren Cloud-Speicherort.

---

## ✍️ Autor
Dieses System wurde von **[Dein Name Hier]** entworfen, erstellt und dokumentiert.
*   **GitHub:** [ridvanyigit](https://github.com/kullanici-adiniz)
*   **LinkedIn:** [Ridvan Yigit](https://linkedin.com/in/profiliniz)
*   **Website:** [www.ridvanyigit.com](https://www.ridvanyigit.com/)

</details>

<br>

<details id="türkçe-versiyon--turkish-version">
<summary><h2>🇹🇷 Türkçe Versiyon / Turkish Version</h2></summary>

<h1 align="center">Freelancerlar ve Şahıs Şirketleri için Self-Hosted İş Otomasyon ve Analiz Merkezi</h1>

<p align="center">
  Solo girişimcilik faaliyetlerinin temel operasyonlarını kolaylaştırmak için tasarlanmış, sağlam ve kendi sunucusunda barındırılan (self-hosted) bir otomasyon ve analiz altyapısıdır. Bu sistem, popüler ve kullanıcı dostu araçları (Notion, Google Sheets) güçlü ve merkezi bir PostgreSQL veritabanı ile entegre eder. n8n ile süreçler otomatikleşirken, Metabase ile veriler iş zekası panolarına dönüşür.
</p>

---

<div align="center">
  <a href="#-sistem-mimarisi-1"><strong>🏗️ Sistem Mimarisi</strong></a> | 
  <a href="#-ön-gereksinimler-1"><strong>✅ Ön Gereksinimler</strong></a> | 
  <a href="#-temel-kurulum-1"><strong>⚙️ Temel Kurulum</strong></a> | 
  <a href="#-i̇ş-akışları-veri-otomasyonu"><strong>🚀 İş Akışları</strong></a> |
  <a href="#-aşama-3-veri-analizi--görselleştirme-1"><strong>📊 Analiz</strong></a> |
  <a href="#-sistem-operasyon-rehberi-1"><strong> Sistemi Çalışır Tutma</strong></a> |
  <a href="#-karşılaşılan-zorluklar-ve-çözümler-1"><strong>🛠️ Karşılaşılan Zorluklar</strong></a> | 
  <a href="#-bakım--yedekleme-stratejileri"><strong>💾 Bakım & Yedekleme</strong></a>
</div>

---

## 🏗️ Sistem Mimarisi
| Katman | Araç | Sorumluluk | Veri Türü |
| :--- | :--- | :--- | :--- |
| **Arayüz Katmanı** | **Notion** | Müşteri & Proje Yönetimi (CRM/PM) | Yapılandırılmış Metin |
| (Günlük Kullanım) | **Google Sheets** | Finansal Kayıtlar (Gelir/Gider) | Yapılandırılmış Finansal Veri |
| | **Google Drive** | Belge ve Yedekleme Arşivi | Yapılandırılmamış Dosyalar |
| **Otomasyon Katmanı**| **n8n** | "Dijital Yapıştırıcı". Veriyi veritabanına senkronize eder ve yedekleme gibi zamanlanmış görevleri yürütür. | Anlık JSON Verisi |
| (Motor) | (Docker ile) | | |
| **Analiz Katmanı** | **Metabase** | "Beyin". Veritabanına bağlanır, veriyi görselleştirir, panolar oluşturur. | Görsel Grafikler & Panolar |
| (İçgörüler) | (Docker ile) | | |
| **Veri Katmanı** | **PostgreSQL** | "Tek Gerçek Kaynak". Tüm yapılandırılmış veriler için merkezi depolama. | İlişkisel SQL Verisi |
| (Temel) | (Docker ile) | | |

---

## ✅ Ön Gereksinimler
*   **Docker Desktop:** [Docker'ı İndirin](https://www.docker.com/products/docker-desktop/).
*   **Notion Hesabı**.
*   **Google Hesabı**.

---

## ⚙️ Temel Kurulum

### 1. Arka Plan Kurulumu: PostgreSQL & pgAdmin
`sizin-guvenli-sifreniz` kısmını güçlü bir şifre ile değiştirin.```bash
docker run --name business-db -e POSTGRES_PASSWORD=sizin-guvenli-sifreniz -p 5432:5432 -d postgres
docker run --name business-pgadmin -p 8080:80 -e "PGADMIN_DEFAULT_EMAIL=sizin-emailiniz@example.com" -e "PGADMIN_DEFAULT_PASSWORD=sizin-pgadmin-sifreniz" -d dpage/pgadmin4
```

### 2. Otomasyon & Analiz Motoru Kurulumu
```bash
docker run --name n8n -p 5678:5678 -d n8nio/n8n
docker run --name metabase -p 3000:3000 -d metabase/metabase
```

### 3. Docker Ağı Yapılandırması (Kritik Adım!)
```bash
docker stop n8n metabase business-pgadmin business-db
docker network create my-business-net
docker start business-db && docker network connect my-business-net business-db
docker start business-pgadmin && docker network connect my-business-net business-pgadmin
docker start n8n && docker network connect my-business-net n8n
docker start metabase && docker network connect my-business-net metabase
```

### 4. Veritabanı Şeması Oluşturma
1.  `http://localhost:8080` (pgAdmin) adresine gidin.
2.  Yeni bir sunucu bağlantısı ekleyin: **Name:** `Yerel Isletme DB`, **Host:** `business-db`, **Port:** `5432`, **Username:** `postgres`, **Password:** PostgreSQL şifreniz.
3.  `postgres` veritabanı için **Query Tool**'u açın ve şu SQL kodunu çalıştırın:
```sql
CREATE TABLE clients (...);
CREATE TABLE projects (...);
CREATE TABLE transactions (...);
-- (Tam SQL kodu İngilizce bölümünde yer almaktadır)
```

### 5. API Kimlik Bilgileri ve İzinler
**Notion** ve **Google Cloud Platform** için API kimlik bilgileri oluşturmak amacıyla [Karşılaşılan Zorluklar bölümündeki](#-karşılaşılan-zorluklar-ve-çözümler-1) veya resmi belgelerdeki ayrıntılı adımları izleyin. API'leri etkinleştirmek, bir OAuth İstemci ID'si oluşturmak ve kimlik doğrulama hatalarını önlemek için kendinizi GCP'de test kullanıcısı olarak eklemek kritik adımlardır.

---

## 🚀 İş Akışları: Veri Otomasyonu

### İş Akışı 1: Otomatik Müşteri Kaydı
*   **Tetikleyici:** Notion `Kunden` veritabanına yeni bir satır eklenmesi.
*   **Eylemler:** Müşteri için bir Google Drive klasörü oluşturur, ardından PostgreSQL `clients` tablosuna yeni bir kayıt ekler.

### İş Akışı 2: Otomatik Finansal Kayıt
*   **Tetikleyici:** Google Sheets `Einnahmen` (Gelirler) sayfasına yeni bir satır eklenmesi.
*   **Eylem:** Bir **IF düğümü**, "hayalet satırları" filtrelemek için önce tarih sütununun boş olup olmadığını kontrol eder. Veri varsa, PostgreSQL `transactions` tablosuna yeni bir kayıt ekler.

### İş Akışı 3: Otomatik Aylık Notion Yedeklemesi
*   **Tetikleyici:** Her ayın 1'inde, sabah 3'te çalışacak şekilde ayarlanmış bir **`Schedule`** düğümü.
*   **Eylemler (Paralel Kollar):**
    1.  **Kol 1 (Müşteriler):** Bir `Notion` düğümü (`Tümünü Getir`) tüm müşteri verilerini çeker -> Bir `Dosyaya Dönüştür` düğümü bunu CSV'ye çevirir -> Bir `Google Drive` düğümü, dosyayı dinamik bir isimle (`Musteri_Yedek_{{$now.toFormat('yyyy-MM-dd')}}.csv`) özel bir yedekleme klasörüne yükler.
    2.  **Kollar 2 & 3:** Aynı işlem `Projeler` ve `Görevler` veritabanları için tekrarlanır.

---

## 📊 Aşama 3: Veri Analizi & Görselleştirme
Metabase ile verileri içgörülere dönüştürme zamanı.

### 1. Metabase'i Veritabanınıza Bağlayın
1.  `http://localhost:3000` adresine gidin ve kurulum sihirbazını tamamlayın.
2.  **Yönetici Ayarları (⚙️) -> Veritabanları -> Veritabanı Ekle**'ye gidin.
3.  Aşağıdaki bağlantı ayrıntılarını girin:
    *   **Veritabanı türü:** `PostgreSQL`
    *   **Host:** `business-db`
    *   **Şifre:** PostgreSQL şifreniz.
    *   ... (diğer detaylar yukarıdaki gibi)

### 2. İlk İçgörünüzü Yaratın (Bir "Soru")
"Aylık Net Ciro" grafiği oluşturalım.
1.  **`+ Yeni` -> `Soru`**'ya tıklayın.
2.  **`Ham Veri` -> Veritabanınız -> `Transactions`**'ı seçin.
3.  Düzenleyicide: **`Özetle`** -> **`Toplamı` -> `Net Amount`**. Ardından **`Grupla`** -> **`Transaction Date` -> `Aya Göre`**.
4.  **`Görselleştir`**'e tıklayın ve soruyu "Aylık Net Ciro" olarak **`Kaydedin`**.

### 3. Komuta Merkezinizi İnşa Edin (Bir "Gösterge Paneli")
1.  **`+ Yeni` -> `Gösterge Paneli`**'ne tıklayın.
2.  Panoya "İşletme Genel Bakış" gibi bir isim verin.
3.  **`+`** simgesine tıklayarak kaydettiğiniz soruyu ekleyin ve panoyu **`Kaydedin`**.

---

## ⚙️ Sistem Operasyon Rehberi

### Kusursuz Çalışma Koşulları
Tüm sistem iki koşul altında sürekli ve otonom olarak çalışır:
1.  **Ana Makine Çalışıyor:** Bilgisayarınız açık olmalıdır.
2.  **Docker Desktop Uygulaması Çalışıyor:** Docker motoru aktif olmalıdır (menü çubuğundaki balina 🐳 simgesiyle doğrulanabilir).

### Sistemi Durduran Senaryolar
Sistem aşağıdaki durumlarda çalışmayı durdurur:
*   Ana makine kapatılırsa veya yeniden başlatılırsa.
*   Docker Desktop uygulamasından manuel olarak çıkış yaparsanız.
*   Bir konteyner terminal üzerinden manuel olarak durdurulursa.

### Sistemi Yeniden Başlatma Protokolü
Sistem beklendiği gibi çalışmıyorsa bu protokolü izleyin:

**1. Docker'ın Çalıştığını Doğrulayın:** Docker Desktop uygulamasının açık olduğundan emin olun.
**2. Konteyner Durumunu Kontrol Edin:** Terminali açın ve `docker ps -a` komutunu çalıştırın. `STATUS` sütununda `Up` yazmayan her konteynerin başlatılması gerekir.
**3. Durdurulmuş Konteynerleri Başlatın:**
```bash
# Örnek: n8n konteyneri durmuşsa
docker start n8n

# Gerekirse tüm ana konteynerleri başlatın
docker start business-db business-pgadmin n8n metabase
```

---

## 🛠️ Karşılaşılan Zorluklar ve Çözümler
*   **Hata:** PostgreSQL düğümünde `Couldn’t connect...` & Terminal'de `ping: bad address 'business-db'`.
    *   **Neden:** Konteynerler paylaşılan bir Docker ağında değildi.
    *   **Çözüm:** Özel bir ağ (`my-business-net`) oluşturmak ve tüm konteynerleri ona bağlamak.

*   **Hata:** Google ile kimlik doğrulaması sırasında `Error 403: access_denied`.
    *   **Neden:** Kimlik doğrulaması yapan kullanıcı, Google Cloud projesinin OAuth ekranında "Test kullanıcısı" olarak listelenmemişti.
    *   **Çözüm:** E-postanızı GCP Konsolu'ndaki **Test users** listesine eklemek.

*   **Hata:** `Google... API has not been used...`.
    *   **Neden:** İlgili API, GCP projesi için etkinleştirilmemişti.
    *   **Çözüm:** GCP Konsolu'nun **Kütüphane**'sinde gerekli API'yi bulup **ETKİNLEŞTİRMEK**.

*   **Sorun:** İş akışı, boş Google E-Tablolar satırlarında hata veriyor.
    *   **Neden:** Tetikleyici, formül içeren satırları geçerli veri olarak okur ve hata veren boş değerler gönderir.
    *   **Çözüm:** Tarih gibi anahtar bir sütunun boş olup olmadığını kontrol eden bir **IF düğümü** eklemek.

*   **Hata:** `violates foreign key constraint...`.
    *   **Neden:** n8n, boş yabancı anahtar alanları için varsayılan olarak `0` gönderiyordu.
    *   **Çözüm:** PostgreSQL düğümünde, yabancı anahtar alanlarını (`client_id`, `project_id`) `{{ null }}` ifadesiyle ayarlayarak kasıtlı olarak boş olduğunu belirtmek.

---

## 💾 Bakım & Yedekleme Stratejileri

### 1. Otomatik Aylık Notion Yedeklemesi (n8n ile)
[İş Akışları bölümünde](#-i̇ş-akışları-veri-otomasyonu) detaylandırılan bu workflow, her ayın başında Notion veritabanlarınızı otomatik olarak CSV formatında Google Drive'a yedekler.

### 2. Manuel Aylık PostgreSQL Yedeklemesi
Bu işlem, veritabanınızın tam bir teknik anlık görüntüsünü oluşturur.
```bash
# Masaüstünüze gidin
cd ~/Desktop

# Konteyner içinde pg_dumpall komutunu çalıştırarak tam bir yedek oluşturun
docker exec business-db pg_dumpall -U postgres > backup_$(date +%Y-%m-%d).sql
```
Oluşturulan `.sql` dosyasını manuel olarak Google Drive gibi güvenli bir bulut konumuna sürükleyin.

---

## ✍️ Yazar
Bu sistem **[Adınız Soyadınız]** tarafından tasarlanmış, inşa edilmiş ve belgelenmiştir.
*   **GitHub:** [ridvanyigit](https://github.com/kullanici-adiniz)
*   **LinkedIn:** [Ridvan Yigit](https://linkedin.com/in/profiliniz)
*   **Website:** [www.ridvanyigit.com](https://www.ridvanyigit.com/)

</details>
