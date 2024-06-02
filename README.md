@@ -216,7 +216,7 @@ Split query
.ToPageList(1,2);　
``` 

### Feature10 : Big data insert or update 
### Feature10 : Big data insert or update 
```cs
10.1 BulkCopy
db.Fastest<Order>().BulkCopy(lstData);//insert
0 comments on commit cbaf343
