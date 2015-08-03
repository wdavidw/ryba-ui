
module.exports =
  hdfs:
    principal: 'ryba@HADOOP.RYBA'
    password: 'test123'
  fetch:
    urls: [
      "https://worker1.ryba:50475/jmx"
      "https://worker2.ryba:50475/jmx"
    ]
