from pyspark.sql import SparkSession
from pyspark.sql.functions import col, to_date

# Initialize SparkSession
spark = SparkSession.builder \
    .appName("Transform Transactions") \
    .getOrCreate()

# Path to GCS CSV file
gcs_input_path = "gs://dataprocproject-460907-raw-data/input/transactions.csv"

# Read CSV from GCS
df = spark.read.option("header", "true").csv(gcs_input_path)

# Basic transformations
df_transformed = df.withColumn("amount", col("amount").cast("double")) \
    .withColumn("transaction_date", to_date(col("transaction_date"), "yyyy-MM-dd")) \
    .filter(col("amount").isNotNull())

# Write to BigQuery
df_transformed.write \
    .format("bigquery") \
    .option("table", "dataprocproject-460907.banking.transaction_summary") \
    .option("temporaryGcsBucket", "dataprocproject-460907-temp-bq") \
    .mode("overwrite") \
    .save()

print("✅ Transformation and load to BigQuery completed.")
