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

  * Converts decimal format (`.` → `,`) for European compatibility
  * Keeps original data unchanged

* 📊 **Plane Segmentation**

  * Detects plane values:

    ```
    0.45, 0.58, 0.81, 1.3
    ```
  * Uses columns **AP** and **AQ**
  * Separates segments with empty rows

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

## 📁 Project Structure

```bash
matlab-excel-processor/
│
├── setup_project.m              # Setup script (run once)
├── batch_excel_processor.m      # Main processing script
├── README.md                    # Documentation
├── LICENSE                      # MIT License
├── .gitignore                   # Git ignore rules
│
├── input/                       # Place Excel files here
│   └── .gitkeep
│
└── output/                      # Processed files appear here
    └── .gitkeep
```

---

## 🏗️ Project Setup (Automated)

You can automatically create the full project structure using the setup script.

### Run in MATLAB:

```matlab
setup_project()
```

This will generate:

* Required folders (`input/`, `output/`)
* `.gitignore`
* `README.md`
* `LICENSE`
* Main processing script

---

## 🚀 Usage

### Step 1: Setup Project (Run Once)

```matlab
setup_project()
```

---

### Step 2: Add Input Files

Place your `.xlsx` files inside the `input/` folder.

---

### Step 3: Run Processing Pipeline

```matlab
batch_excel_processor()
```

---

### Step 4: Get Results

Processed files will appear in the `output/` folder.

Each output file contains:

| Sheet Name    | Description                      |
| ------------- | -------------------------------- |
| Original Data | Raw input data                   |
| Cleaned Data  | Cleaned + segmented data         |
| Statistics    | Segment-wise statistical results |

---

## ⚙️ Configuration

You can modify parameters inside `batch_excel_processor.m`:

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

For each detected segment:

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
* Row boundaries are **automatically detected**
* Each file is processed independently
* Original data is preserved
* Empty rows are inserted between segments for clarity

---

## 🧪 Requirements

* MATLAB **R2016b or later**
* Statistics and Machine Learning Toolbox (for `quantile`)

---

## 🧠 Use Cases

* Optical / vision science data analysis
* Experimental dataset segmentation
* Batch preprocessing pipelines
* Research data workflows

---

## 📜 License

This project is licensed under the MIT License.

---

## 👤 Author

Ajeem S
Optometry & Vision Science

---

## 🚀 Future Improvements

* GUI (MATLAB App Designer)
* Data visualization (plots per segment)
* CSV support
* Automated report generation (PDF)
* Integration with research pipelines

---

## ⭐ Support

If this project helped you:

* Star the repository
* Share it with others
* Contribute improvements

---
