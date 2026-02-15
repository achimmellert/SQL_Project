# Book Sharing Platform - Database Backend

Dieses Repository beinhaltet das Datenbank-Backend für eine lokale Book-Sharing-Plattform. Das System ermöglicht es Nutzern, physische Buchexemplare basierend auf geographischer Nähe (Geo-Location) zu suchen, auszuleihen und zu bewerten.

Besonderheit dieses Projekts ist der **"Thick Database"-Ansatz**: Ein Großteil der Geschäftslogik, Datenvalidierung und Automatisierung (z. B. Status-Updates, Geodaten-Berechnung) wird direkt durch SQL-Trigger und Events ausgeführt, um maximale Datenintegrität zu gewährleisten.

## 📋 Voraussetzungen

Bevor du startest, stelle sicher, dass folgende Software installiert ist:

* **MySQL Server** (Version 8.0 oder höher empfohlen für Spatial-Support und CTEs)
* **MySQL Workbench**, **DBeaver** oder ein anderer SQL-Client
* **Git**

## 🚀 Installation & Setup

Folge diesen Schritten, um die Datenbank lokal aufzusetzen.

### 1. Repository klonen
```bash
git clone [https://github.com/achimmellert/SQL_Project.git](https://github.com/achimmellert/SQL_Project.git)
cd book-sharing-db
