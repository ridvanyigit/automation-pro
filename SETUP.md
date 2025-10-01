<div align="center">
  <h1 style="border-bottom: 2px solid #555; padding-bottom: 10px;">Setup Guide: Self-Hosted Business Hub</h1>
  <p>This guide provides step-by-step instructions to deploy the entire automation and analytics suite on your local machine using Docker Compose.</p>
</div>

---

### **✅ Prerequisite**

Before you begin, you only need one thing installed on your system:
- **[Docker Desktop](https://www.docker.com/products/docker-desktop/):** Please ensure it is installed and running before you proceed.

---

<div style="background-color: #000205ff; border: 1px solid #000205ff; border-radius: 8px; margin-bottom: 20px;">
  <h3 style="margin: 0; padding: 12px 16px; background-color: #000205ff; color: #eceef1ff; border-top-left-radius: 8px; border-top-right-radius: 8px; border-bottom: 1px solid #000205ff;">
    ⚙️ Step 1: Get the Project & Create Your Configuration
  </h3>
  <div style="padding: 16px;">
    <p>First, we'll get the project files and create a secure configuration file for your passwords and settings.</p>
    <ol>
      <li>
        <strong>Clone the Repository</strong><br>
        Open your terminal and clone this project to your desired location (e.g., your Desktop).
        <br>
        <pre><code style="background-color: #160202ff; padding: 5px; border-radius: 4px;">git clone https://github.com/your-username/self-hosted-business-hub.git</code></pre>
      </li>
      <br>
      <li>
        <strong>Create the Environment File</strong><br>
        Navigate into the project directory. You will see a file named <code>.env.example</code>. This is your template.
        <br>
        <pre><code style="background-color: #160202ff; padding: 5px; border-radius: 4px;">cd self-hosted-business-hub
cp .env.example .env</code></pre>
        <p>This command creates a new <code>.env</code> file, which is ignored by Git to keep your secrets safe.</p>
      </li>
      <br>
      <li>
        <strong>Edit the Configuration</strong><br>
        Open the new <code>.env</code> file with any text editor. Fill in the required values. These will be your personal credentials for the services.
        <blockquote style="border-left: 4px solid #f40505ff; padding-left: 1rem; color: #f40505ff;">
          <p>❗ <strong>Important:</strong> Do not use default or easy-to-guess passwords. Choose strong, unique passwords for the database and pgAdmin.</p>
        </blockquote>
      </li>
    </ol>
  </div>
</div>

<div style="background-color: #000205ff; border: 1px solid #000205ff; border-radius: 8px; margin-bottom: 20px;">
  <h3 style="margin: 0; padding: 12px 16px; background-color: #000205ff; color: #eceef1ff; border-top-left-radius: 8px; border-top-right-radius: 8px; border-bottom: 1px solid #000205ff;">
    🚀 Step 2: Launch the Entire System with One Command
  </h3>
  <div style="padding: 16px;">
    <p>With your configuration set, you can now launch all services with a single command. This is the magic of Docker Compose.</p>
    <ol>
      <li>
        <strong>Run Docker Compose</strong><br>
        Make sure you are inside the project's main directory in your terminal, then run:
        <br>
        <pre><code style="background-color: #000205ff; padding: 5px; border-radius: 4px;">docker-compose up -d</code></pre>
        <p>This command reads the <code>docker-compose.yml</code> file and automatically creates and starts all the necessary containers (PostgreSQL, pgAdmin, n8n, Metabase) and the network that connects them.</p>
        <p><em>This might take a few minutes the first time as Docker downloads the images.</em></p>
      </li>
      <br>
      <li>
        <strong>Verify Everything is Running</strong><br>
        After a few minutes, run the following command to check if all four containers are up and running:
        <br>
        <pre><code style="background-color: #000205ff; padding: 5px; border-radius: 4px;">docker ps</code></pre>
        <p>You should see <code>business-db</code>, <code>business-pgadmin</code>, <code>n8n</code>, and <code>metabase</code> in the list with a status of "Up".</p>
      </li>
    </ol>
  </div>
</div>

<div style="background-color: #000205ff; border: 1px solid #000205ff; border-radius: 8px; margin-bottom: 20px;">
  <h3 style="margin: 0; padding: 12px 16px; background-color: #000205ff; color: #eceef1ff; border-top-left-radius: 8px; border-top-right-radius: 8px; border-bottom: 1px solid #000205ff;">
    💡 Step 3: Post-Launch Configuration
  </h3>
  <div style="padding: 16px;">
    <p>Your digital office is now running. The final step is to configure each service to work with your data and workflows.</p>

<details style="margin-bottom: 10px; border: 1px solid #000205ff; border-radius: 6px;">
  <summary style="padding: 10px; font-weight: bold; cursor: pointer;">3.1: Initialize the Database Schema (pgAdmin)</summary>
  <div style="padding: 15px; border-top: 1px solid #000205ff;">
    <ol>
      <li>Navigate to <strong><code>http://localhost:8080</code></strong> in your browser.</li>
      <li>Log in to pgAdmin using the <code>PGADMIN_EMAIL</code> and <code>PGADMIN_PASSWORD</code> you set in your <code>.env</code> file.</li>
      <li>Add a new server connection:
        <ul>
          <li><strong>Host:</strong> <code>business-db</code></li>
          <li><strong>Username:</strong> <code>postgres</code></li>
          <li><strong>Password:</strong> The <code>POSTGRES_PASSWORD</code> from your <code>.env</code> file.</li>
        </ul>
      </li>
      <li>Open the <strong>Query Tool</strong> for the <code>postgres</code> database.</li>
      <li>Copy the entire content of the <code>sql-schema/schema.sql</code> file, paste it into the Query Tool, and execute it to create your tables.</li>
    </ol>
  </div>
</details>

<details style="margin-bottom: 10px; border: 1px solid #000205ff; border-radius: 6px;">
  <summary style="padding: 10px; font-weight: bold; cursor: pointer;">3.2: Configure Automations (n8n)</summary>
  <div style="padding: 15px; border-top: 1px solid #000205ff;">
    <ol>
      <li>Navigate to <strong><code>http://localhost:5678</code></strong> and set up your n8n admin user.</li>
      <li>For each workflow, go to <strong><code>File -> Import from file...</code></strong> and import the <code>.json</code> files from the <code>n8n-workflows</code> directory one by one.</li>
      <li><strong>Crucial Step:</strong> After importing, you must re-create the credentials for each service.
        <ul>
          <li>In the <strong>Notion</strong> nodes, create a new credential and enter your own Notion API key.</li>
          <li>In the <strong>Google Drive/Sheets</strong> nodes, create new credentials using your own Google Cloud Client ID and Secret.</li>
          <li>In the <strong>PostgreSQL</strong> nodes, create a new credential using the database password from your <code>.env</code> file.</li>
        </ul>
      </li>
      <li>Once the credentials are set and the nodes are tested, activate each workflow using the toggle in the top-right corner.</li>
    </ol>
  </div>
</details>

<details style="border: 1px solid #000205ff; border-radius: 6px;">
  <summary style="padding: 10px; font-weight: bold; cursor: pointer;">3.3: Configure Analytics (Metabase)</summary>
  <div style="padding: 15px; border-top: 1px solid #000205ff;">
    <ol>
      <li>Navigate to <strong><code>http://localhost:3000</code></strong> and set up your Metabase admin user.</li>
      <li>During the setup wizard (or later in Admin settings), add your database with the same connection details used for pgAdmin:
        <ul>
          <li><strong>Host:</strong> <code>business-db</code></li>
          <li><strong>Database name:</strong> <code>postgres</code></li>
          <li><strong>Username:</strong> <code>postgres</code></li>
          <li><strong>Password:</strong> The <code>POSTGRES_PASSWORD</code> from your <code>.env</code> file.</li>
          <li><strong>SSL:</strong> Disabled.</li>
        </ul>
      </li>
      <li>Once connected, you can start exploring your data by clicking <strong><code>+ New -> Question</code></strong> to build your analytics dashboard.</li>
    </ol>
  </div>
</details>

  </div>
</div>

---

<div align="center">
  <h2>🎉 Congratulations! 🎉</h2>
  <p>Your self-hosted business hub is now fully operational. New data in Notion and Google Sheets will automatically sync to your database, ready for you to analyze in Metabase.</p>
</div>