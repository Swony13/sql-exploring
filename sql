var newObj= value.GetType().GetMethod("ExecuteCommand").Invoke(value, new object[] { });
            return (int)newObj;
        }
        public StorageableCommonMethodInfo IgnoreColumns(params string[] ignoreColumns)
        {
            PropertyInfo property = ObjectValue.GetType().GetProperty(type);
            var value = property.GetValue(ObjectValue);
            var newObj = value.GetType().GetMyMethod("IgnoreColumns", 1, typeof(string[])).Invoke(value, new object[] { ignoreColumns });
            StorageableCommonMethodInfo result = new StorageableCommonMethodInfo();
            result.Value = newObj;
            return result;
        } 
    }
    public class StorageableCommonMethodInfo
    {
        public object Value { get;  set; }
        public int ExecuteCommand()
        { 
            var newObj = Value.GetType().GetMethod("ExecuteCommand").Invoke(Value, new object[] { });
            return (int)newObj;
        }
    }

    public class StorageableSplitTableMethodInfo
