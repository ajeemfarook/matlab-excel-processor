# MATLAB Excel Batch Processor

Automated MATLAB pipeline for batch processing Excel files with **data cleaning**, **plane-based segmentation**, and **statistical analysis**.

---

## 📌 Overview

This project provides a fully automated workflow:

**Input Folder → Data Cleaning → Plane Segmentation → Statistical Analysis → Output Folder**

Each Excel file is processed independently and exported with structured results.

---

## ✨ Features

* 🔁 **Batch Processing**

  * Automatically processes all `.xlsx` files in the input folder

* 🧹 **Data Cleaning**

  * Converts decimal format (`.` → `,`) 
  * Preserves original dataset
  * Excludes columns **A & B**

* 📊 **Plane Segmentation**

  * Detects plane values:

    ```
    0.45, 0.58, 0.81, 1.3
    ```
  * Uses columns **AP** and **AQ**
  * Segments data based on first occurrence
  * Inserts empty rows between segments

* 📈 **Statistical Analysis**

  * Computed per segment:

    * Mean
    * Standard Deviation
    * Median
    * Quartiles (Q1, Q3)
    * Interquartile Range (IQR)
  * Applied to:

    * Column **T** (Left)
    * Column **AK** (Right)

* 🏗️ **Automated Project Setup**

  * One command generates full project structure

---

## 📝 Pipeline Workflow

```bash
┌─────────────────────────────────────────────────────────┐
│                    INPUT FOLDER                         │
│              (Multiple Excel files)                     │
└─────────────────────┬───────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────┐
│  1. READ EXCEL FILE                                     │
│     - Load data with original headers                   │
└─────────────────────┬───────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────┐
│  2. DATA CLEANING                                       │
│     - Replace '.' with ',' (except columns A & B)        │
└─────────────────────┬───────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────┐
│  3. PLANE SEGMENTATION                                  │
│     - Detect plane values in columns AP & AQ            │
│     - Segment data by first occurrence of each plane    │
│     - Insert empty rows between segments                │
└─────────────────────┬───────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────┐
│  4. STATISTICAL ANALYSIS                                │
│     - Compute Mean, SD, Median, Q1, Q3, IQR              │
│     - For each segment                                  │
│     - For columns T (Left) and AK (Right)               │
└─────────────────────┬───────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────┐
│                    OUTPUT FOLDER                         │
│     ┌─────────────┬──────────────┬────────────┐         │
│     │  Original   │   Cleaned    │ Statistics │         │
│     │    Data     │    Data      │            │         │
│     └─────────────┴──────────────┴────────────┘         │
└─────────────────────────────────────────────────────────┘
```

---

## 📌 Example

**Input file:**
`data_file.xlsx`

### Processing Steps:

* Detects plane values (`0.45`, `0.58`, `0.81`, `1.3`) in columns **AP & AQ**
* Creates segments based on first occurrence of each plane
* Inserts empty rows between segments
* Computes statistics for each segment

### Output:

`data_file_processed.xlsx` with 3 sheets:

* Original Data
* Cleaned Data
* Statistics

---

## 📁 Project Structure

```bash
matlab-excel-processor/
│
├── batch_excel_processor.m      # Main processing script
├── README.md                    # Documentation
├── LICENSE                      # MIT License
├── stat_function.m              # helper function
│
├── input/                       # Place Excel files here
│   └── .gitkeep
│
└── output/                      # Processed files appear here
    └── .gitkeep
```

---

## 🏗️ Project Setup (Automated)

Run once in MATLAB:

```matlab
setup_project()
```

---

## 🚀 Usage

### Step 1: Setup Project

```matlab
setup_project()
```

### Step 2: Add Excel Files

Place `.xlsx` files inside the `input/` folder.

### Step 3: Run Processing

```matlab
batch_excel_processor()
```

### Step 4: Get Results

Processed files will appear in the `output/` folder.

---

## ⚙️ Configuration

Modify inside `batch_excel_processor.m`:

```matlab
input_folder = 'input/';
output_folder = 'output/';

plane_values = [0.45, 0.58, 0.81, 1.3];

COL_AP = 43;  % Column AP
COL_AQ = 44;  % Column AQ
COL_T  = 20;  % Column T (Left)
COL_AK = 37;  % Column AK (Right)
```

---

## 📊 Statistical Details

### Left (Column T)

* Mean
* Standard Deviation
* Median
* Q1, Q3
* IQR = Q3 − Q1

### Right (Column AK)

* Mean
* Standard Deviation
* Median
* Q1, Q3
* IQR = Q3 − Q1

---

## ⚠️ Important Notes

* Segmentation is based on **first occurrence of plane values**
* Boundaries are automatically detected
* Small variation (~0.001) may occur compared to manual calculations due to segmentation differences
* Each file is processed independently
* Original data is preserved

---

## 🧪 Requirements

* MATLAB **R2016b or later**
* Statistics and Machine Learning Toolbox

---

## 🧠 Use Cases

* Optical / vision science data analysis
* Experimental dataset segmentation
* Batch preprocessing workflows
* Research automation

## 📜 License

MIT License

---

## 👤 Author

Ajeem S
Optometry & Vision Science

---

## 🚀 Future Improvements

* GUI (MATLAB App Designer)
* Data visualization (plots per segment)
* CSV support
* Automated reporting

