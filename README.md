# MATLAB Excel Batch Processor

Automated MATLAB pipeline for batch processing Excel files with **data cleaning**, **plane-based segmentation**, and **statistical analysis**.

---

## 📌 Overview

This project processes multiple Excel files automatically using a structured pipeline:

**Input Folder → Data Cleaning → Plane Segmentation → Statistical Analysis → Output Folder**

Each Excel file is handled independently and exported with organized results.

---

## ✨ Features

* 🔁 **Batch Processing**

  * Automatically processes all `.xlsx` files in a folder

* 🧹 **Data Cleaning**

  * Converts decimal format from `.` to `,` (European format)
  * Preserves original dataset

* 📊 **Plane Segmentation**

  * Detects and separates data based on plane values:

    ```
    0.45, 0.58, 0.81, 1.3
    ```
  * Uses columns **AP** and **AQ**
  * Inserts empty rows between segments

* 📈 **Statistical Analysis**

  * Computed per segment:

    * Mean
    * Standard Deviation
    * Median
    * Quartiles (Q1, Q3)
    * Interquartile Range (IQR)
  * Applied on:

    * Column **T** (Left)
    * Column **AK** (Right)

---

## 📁 Project Structure

```
matlab-excel-processor/
├── batch_excel_processor.m
├── README.md
├── LICENSE
├── stat_functions.m
├── input/
│   └── .gitkeep
├── output/
│   └── .gitkeep
```

---

## ⚙️ Requirements

* MATLAB **R2016b or later**
* Statistics and Machine Learning Toolbox (for `quantile` function)

---

## 🚀 Usage

### 1. Add Input Files

Place your Excel files (`.xlsx`) inside the `input/` folder.

---

### 2. Run the Script in MATLAB

```matlab
batch_excel_processor()
```

---

### 3. Get Results

Processed files will appear in the `output/` folder.

Each output file contains:

| Sheet Name    | Description                  |
| ------------- | ---------------------------- |
| Original Data | Raw input data               |
| Cleaned Data  | Processed + segmented data   |
| Statistics    | Computed metrics per segment |

---

## ⚙️ Configuration

You can modify parameters inside the script:

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

## ⚠️ Notes

* Segmentation is based on **first occurrence of plane values**
* Row boundaries are **automatically detected**
* Each file is processed independently
* Original data remains unchanged

---

## 🧠 Use Cases

* Optical / experimental data analysis
* Batch preprocessing of measurement datasets
* Research workflows requiring segmentation + statistics

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
* CSV support
* Visualization (plots per segment)
* Export to PDF reports

---
