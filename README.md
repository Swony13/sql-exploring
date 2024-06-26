<p  align="center">
    <span>English</span> |  
    <a  href="https://www.donet5.com/Home/Doc"><font color="red">中文</font></a>
</p>
 
 <a target="_blank" href="https://github.com/donet5/SqlSugar/wiki/NUGET">Nuget</a>| <a href="https://www.donet5.com/Home/Doc?typeId=1187">Query</a> | <a  target="_blank" href="https://www.donet5.com/Home/Doc?typeId=1193"> Insert </a> |<a  target="_blank" href="https://www.donet5.com/Home/Doc?typeId=1191">Update</a>|    <a  target="_blank" href="https://www.donet5.com/Home/Doc?typeId=1195">Delete</a>    | 
<a target="_blank" href="https://github.com/donet5/SqlSugar/wiki/Create--database-operation-object"> Start guide</a>  | <a target="_bank" href="https://www.donet5.com/Home/Doc?typeId=1185">Join query </a> |<a href="https://www.donet5.com/Home/Doc?typeId=2422">Insert without entity </a> | <a href="https://www.donet5.com/Home/Doc?typeId=2423">Update without entity</a>  | <a href="https://www.donet5.com/Home/Doc?typeId=2424">  Delete without entity </a>   |     |
|<a href="https://www.donet5.com/Home/Doc?typeId=2246">Multiple databases</a> | <a target="_bank" href="https://www.donet5.com/Home/Doc?typeId=1188">Include query</a>|<a target="_bank" href="https://www.donet5.com/Home/Doc?typeId=2430">Include Insert</a>| <a target="_bank" href="https://www.donet5.com/Home/Doc?typeId=2432">Include Update</a>| <a target="_bank" href="https://www.donet5.com/Home/Doc?typeId=2431">Include Delete</a> 
 |<a  href="https://www.donet5.com/Home/Doc"><font color="red"></font></a>|<a  href="https://www.donet5.com/Home/Doc?typeId=2244">Cross database query</a>|<a  href="https://www.donet5.com/Home/Doc?typeId=2420">Insert by json</a>|<a  href="https://www.donet5.com/Home/Doc?typeId=2420">Update by json</a>|<a  href="https://www.donet5.com/Home/Doc?typeId=2420">Delete by json</a>|
##  Feature characteristic
###  Feature1 : Join query  
Super simple query syntax
```cs
var query  = db.Queryable<Order>()
            .LeftJoin<Custom>  ((o, cus) => o.CustomId == cus.Id)
            .LeftJoin<OrderItem> ((o, cus, oritem ) => o.Id == oritem.OrderId)
            .LeftJoin<OrderItem> ((o, cus, oritem , oritem2) => o.Id == oritem2.OrderId)
            .Where(o => o.Id == 1)  
            .Select((o, cus) => new ViewOrder { Id = o.Id, CustomName = cus.Name })
            .ToList();   
```
```sql
SELECT
  [o].[Id] AS [Id],
  [cus].[Name] AS [CustomName]
FROM
  [Order] o
  Left JOIN [Custom] cus ON ([o].[CustomId] = [cus].[Id])
  Left JOIN [OrderDetail] oritem ON ([o].[Id] = [oritem].[OrderId])
  Left JOIN [OrderDetail] oritem2 ON ([o].[Id] = [oritem2].[OrderId])
WHERE
  ([o].[Id] = @Id0)
``` 
###   Feature2 :Include Query、Insert、Delete and Update
```cs
//Includes
var list=db.Queryable<Test>()
           .Includes(x => x.Provinces,x=>x.Citys ,x=>x.Street) //multi-level
           .Includes(x => x.ClassInfo) 
           .ToList();
//Includes+left join        
var list5= db.Queryable<Student_004>()
           .Includes(x => x.school_001, x => x.rooms)
           .Includes(x => x.books)
           .LeftJoin<Order>((x, y) => x.Id==y.sid)
           .Select((x,y) => new Student_004DTO
           {
               SchoolId = x.SchoolId,
               books = x.books,
               school_001 = x.school_001,
               Name=y.Name
           })
           .ToList();          
```
###   Feature3 : Page query
```cs
 int pageIndex = 1; 
 int pageSize = 20;
 int totalCount=0;
 var page = db.Queryable<Student>().ToPageList(pageIndex, pageSize, ref totalCount);
```
 
###    Feature4 : Dynamic expression
```cs
var names= new string [] { "a","b"};
Expressionable<Order> exp = new Expressionable<Order>();
foreach (var item in names)
{
    exp.Or(it => it.Name.Contains(item.ToString()));
}
var list= db.Queryable<Order>().Where(exp.ToExpression()).ToList();
 ```
 ```sql
SELECT [Id],[Name],[Price],[CreateTime],[CustomId]
        FROM [Order]  WHERE (
                      ([Name] like '%'+ CAST(@MethodConst0 AS NVARCHAR(MAX))+'%') OR 
                      ([Name] like '%'+ CAST(@MethodConst1 AS NVARCHAR(MAX))+'%')
                     )
```
###   Feature5 : Multi-tenant transaction
```cs
//Creaate  database object
SqlSugarClient db = new SqlSugarClient(new List<ConnectionConfig>()
{
    new ConnectionConfig(){ ConfigId="0", DbType=DbType.SqlServer,  ConnectionString=Config.ConnectionString, IsAutoCloseConnection=true },
    new ConnectionConfig(){ ConfigId="1", DbType=DbType.MySql, ConnectionString=Config.ConnectionString4 ,IsAutoCloseConnection=true}
});
var mysqldb = db.GetConnection("1");//mysql db
var sqlServerdb = db.GetConnection("0");// sqlserver db
 
db.BeginTran();
            mysqldb.Insertable(new Order()
            {
                CreateTime = DateTime.Now,
                CustomId = 1,
                Name = "a",
                Price = 1
            }).ExecuteCommand();
            mysqldb.Queryable<Order>().ToList();
            sqlServerdb.Queryable<Order>().ToList();
db.CommitTran();
```
###  Feature6 : Singleton Pattern
Implement transactions across methods
```CS
public static SqlSugarScope Db = new SqlSugarScope(new ConnectionConfig()
 {
            DbType = SqlSugar.DbType.SqlServer,
            ConnectionString = Config.ConnectionString,
            IsAutoCloseConnection = true 
  },
  db=> {
            db.Aop.OnLogExecuting = (s, p) =>
            {
                Console.WriteLine(s);
            };
 });
 
 
  using (var tran = Db.UseTran())
  {
          
              
               new Test2().Insert(XX);
               new Test1().Insert(XX);
               ..... 
                ....
                         
             tran.CommitTran(); 
 }
```
### Feature7 : Query filter
```cs
//set filter
db.QueryFilter.Add(new TableFilterItem<Order>(it => it.Name.Contains("a")));  
 
   
db.Queryable<Order>().ToList();
//SELECT [Id],[Name],[Price],[CreateTime],[CustomId] FROM [Order]  WHERE  ([Name] like '%'+@MethodConst0+'%')  
db.Queryable<OrderItem, Order>((i, o) => i.OrderId == o.Id)
        .Where(i => i.OrderId != 0)
        .Select("i.*").ToList();
//SELECT i.* FROM [OrderDetail] i  ,[Order]  o  WHERE ( [i].[OrderId] = [o].[Id] )  AND 
//( [i].[OrderId] <> @OrderId0 )  AND  ([o].[Name] like '%'+@MethodConst1+'%')
 
```
### Feature8 : Insert or update 
insert or update 
```cs
Db.Storageable(list2).ExecuteCommand();
Db.Storageable(list2).PageSize(1000).ExecuteCommand();
Db.Storageable(list2).PageSize(1000,exrows=> {   }).ExecuteCommand();
```
 
### Feature9 : Auto split table
Split entity 
```cs
[SplitTable(SplitType.Year)]//Table by year (the table supports year, quarter, month, week and day)
[SugarTable("SplitTestTable_{year}{month}{day}")] 
 public class SplitTestTable
 {
     [SugarColumn(IsPrimaryKey =true)]
     public long Id { get; set; }
 
     public string Name { get; set; }
     
     //When the sub-table field is inserted, which table will be inserted according to this field. 
     //When it is updated and deleted, it can also be convenient to use this field to      
     //find out the related table 
     [SplitField] 
     public DateTime CreateTime { get; set; }
 }
 ```
Split query
```cs
 var lis2t = db.Queryable<OrderSpliteTest>()
.SplitTable(DateTime.Now.Date.AddYears(-1), DateTime.Now)
.ToPageList(1,2);　
``` 

### Feature10 : Big data insert or update 
### Feature10 : Big data insert or update 
```cs
10.1 BulkCopy
db.Fastest<Order>().BulkCopy(lstData);//insert
db.Fastest<Order>().PageSize(100000).BulkCopy(insertObjs);
db.Fastest<System.Data.DataTable>().AS("order").BulkCopy(dataTable);
 
10.2 BulkUpdate
db.Fastest<Order>().BulkUpdate(GetList())//update 
db.Fastest<Order>().PageSize(100000).BulkUpdate(GetList()) 
db.Fastest<Order>().BulkUpdate(GetList(),new string[] { "Id"});//no primary key
db.Fastest<Order>().BulkUpdate(GetList(), new string[]{"id"},
                     new string[]{"name","time"})//Set the updated column
//DataTable                           
db.Fastest<System.Data.DataTable>().AS("Order").BulkUpdate(dataTable,"Id");//Id is primary key
db.Fastest<System.Data.DataTable>().AS("Order").BulkUpdate(dataTable,"Id",Set the updated column);
                          
10.3 BulkMerge （5.1.4.109）
db.Fastest<Order>().BulkMerge(List);
db.Fastest<Order>().PageSize(100000).BulkMerge(List);
 
10.4 BulkQuery
db.Queryable<Order>().ToList();//Slightly faster than Dapper
//Suitable for big data export
List<Order> order = new List<Order>(); 
db.Queryable<Order>().ForEach(it=> { order.Add(it); } ,2000);
10.5 BulkDelete
db.Deleteable<Order>(list).PageSize(1000).ExecuteCommand();
```
