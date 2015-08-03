

## Getting Started

```
npm install
./bin/app
```

## HTML Test pages

*   [nodes_disks](http://localhost:3000/test/nodes_disks.html)   
    Clusters Nodes with disks information   
*   [node_disks](http://localhost:3000/test/node_disks.html)   
    One Node with detailed disks information   
*   [hdfs_nav](http://localhost:3000/test/hdfs_nav.html)   
    DFS Directory Browser   

## Kerberos

```
kadmin \
  -r HADOOP.RYBA \
  -s master1.ryba \
  -p wdavidw/admin@HADOOP.RYBA \
  -w test \
  -q 'addprinc -randkey ryba/ui.ryba@HADOOP.RYBA'
kadmin \
  -r HADOOP.RYBA \
  -s master1.ryba \
  -p wdavidw/admin@HADOOP.RYBA \
  -w test \
  -q 'ktadd -k ./ryba.keytab ryba/ui.ryba@HADOOP.RYBA'
```

