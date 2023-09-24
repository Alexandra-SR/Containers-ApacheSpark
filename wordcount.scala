import org.apache.spark.{SparkConf, SparkContext}

object WordCount {
  def main(args: Array[String]): Unit = {
    if (args.length != 2) {
      println("Usage: WordCount <input_file> <output_file>")
      System.exit(1)
    }

    val inputFile = args(0)
    val outputFile = args(1)

    val conf = new SparkConf().setAppName("WordCount")
    val sc = new SparkContext(conf)

    val textFile = sc.textFile(inputFile)

    val counts = textFile.flatMap(_.split("\\W+"))  // Split on non-word characters
                         .filter(_.nonEmpty)        // Remove empty words
                         .map(_.toLowerCase)        // Convert to lowercase for consistent counting
                         .map((_, 1))               // Map each word to a key/value pair
                         .reduceByKey(_ + _)        // Reduce by key to count occurrences
                         .sortBy(_._2, ascending = false)  // Sort by count

    counts.saveAsTextFile(outputFile)

    sc.stop()
  }
}
