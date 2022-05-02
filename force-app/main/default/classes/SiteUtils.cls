public class SiteUtils {
    
    public static final String sliderConfigType = 'slider';
    public static final String checkboxConfigType = 'checkbox';
    public static final String dropdownConfigType = 'dropdown';
    public static final String dropdownSingleConfigType = 'dropdownSingle';
    public static final String autocompleteConfigType = 'searchbox';
    
    public virtual class ConfigField{
        public String apiName;
        public String label;
        public String tooltip;
        public String category;
        public Boolean isOverflow;
        public String configType;
        
        public ConfigField(String apiName, String label, String tooltip){
            this.apiName = apiName;
            this.label = label;
            this.tooltip = tooltip;
            this.category = 'none';
        }

        public ConfigField(String apiName, String label, String tooltip, String category, Boolean isOverflow){
            this.apiName = apiName;
            this.label = label;
            this.tooltip = tooltip;
            this.category = category;
            this.isOverflow = isOverflow;
        }
    }
    public class ConfigSort extends ConfigField{
        public String name;
        public Boolean sortDesc;
        
        public ConfigSort(String apiName, String label, String tooltip, String name){
            super(apiName, label, tooltip);
            this.name = name;
            this.sortDesc = false;
        }
        
        public ConfigSort(String apiName, String label, String tooltip, String name, Boolean sortDesc){
            super(apiName, label, tooltip);
            this.name = name;
            this.sortDesc = sortDesc;
        }
    }
    public class ConfigCheckbox extends ConfigField{
        public ConfigCheckbox(String apiName, String label, String tooltip){
            super(apiName, label, tooltip);
            this.configType = checkboxConfigType;
        }
        public ConfigCheckbox(String apiName, String label, String tooltip, String category, Boolean isOverflow){
            super(apiName, label, tooltip, category, isOverflow);
            this.configType = checkboxConfigType;
        }
    }
    public class ConfigSlider extends ConfigField{
        public Decimal min;
        public Decimal max;
        public List<Utils.LabelValue> labelValues;
        
        public ConfigSlider(String apiName, String label, String tooltip, Decimal min, Decimal max){
            super(apiName, label, tooltip);
            this.configType = sliderConfigType;
            this.min = min;
            this.max = max;
        }
        
        public ConfigSlider(String apiName, String label, String tooltip, List<Utils.LabelValue> labelValues){
            super(apiName, label, tooltip);
            this.configType = sliderConfigType;
            this.labelValues = labelValues;
        }

        public ConfigSlider(String apiName, String label, String tooltip, List<Utils.LabelValue> labelValues, String category, Boolean isOverflow){
            super(apiName, label, tooltip, category, isOverflow);
            this.configType = sliderConfigType;
            this.labelValues = labelValues;
        }
    }
    public class ConfigDropdown extends ConfigField{
        public List<Utils.LabelValue> options;
        public Boolean isOpen;
        public String valueOther;
        
        public ConfigDropdown(String apiName, String label, String tooltip, List<Utils.LabelValue> options){
            super(apiName, label, tooltip);
            this.configType = dropdownConfigType;
            this.options = options;
        }
        public ConfigDropdown(String apiName, String label, String tooltip, Set<Utils.LabelValue> options){
            super(apiName, label, tooltip);
            this.configType = dropdownConfigType;
            this.options = new List<Utils.LabelValue>(options);
        }
        public ConfigDropdown(String apiName, String label, String tooltip, List<Utils.LabelValue> options, String valueOther){
            super(apiName, label, tooltip);
            this.configType = dropdownConfigType;
            this.options = new List<Utils.LabelValue>(options);
            this.valueOther = valueOther;
        }
        public ConfigDropdown(String apiName, String label, String tooltip, List<Utils.LabelValue> options, String category, Boolean isOverflow){
            super(apiName, label, tooltip, category, isOverflow);
            this.configType = dropdownConfigType;
            this.options = options;
        }
        public ConfigDropdown(String apiName, String label, String tooltip, Set<Utils.LabelValue> options, String category, Boolean isOverflow){
            super(apiName, label, tooltip, category, isOverflow);
            this.configType = dropdownConfigType;
            this.options = new List<Utils.LabelValue>(options);
        }
        public ConfigDropdown(String apiName, String label, String tooltip, List<Utils.LabelValue> options, String category, Boolean isOverflow, Boolean isOpen){
            super(apiName, label, tooltip, category, isOverflow);
            this.configType = dropdownConfigType;
            this.options = options;
            this.isOpen = isOpen;
        }
        public ConfigDropdown(String apiName, String label, String tooltip, Set<Utils.LabelValue> options, String category, Boolean isOverflow, Boolean isOpen){
            super(apiName, label, tooltip, category, isOverflow);
            this.configType = dropdownConfigType;
            this.options = new List<Utils.LabelValue>(options);
            this.isOpen = isOpen;
        }
        public ConfigDropdown(String apiName, String label, String tooltip, List<Utils.LabelValue> options, String category, Boolean isOverflow, Boolean isOpen, Boolean isSingle){
            super(apiName, label, tooltip, category, isOverflow);
            this.configType = isSingle ? dropdownSingleConfigType : dropdownConfigType;
            this.options = new List<Utils.LabelValue>(options);
            this.isOpen = isOpen;
        }
    }
    public class ConfigAutoComplete extends ConfigField{
        public String functionFullName;
        public String functionReverseFullName;
        
        public ConfigAutoComplete(String apiName, String label, String tooltip, String functionFullName, String functionReverseFullName){
            super(apiName, label, tooltip);
            this.configType = autocompleteConfigType;
            this.functionFullName = functionFullName;
            this.functionReverseFullName = functionReverseFullName;
        }
        public ConfigAutoComplete(String apiName, String label, String tooltip, String functionFullName, String functionReverseFullName, String category, Boolean isOverflow){
            super(apiName, label, tooltip, category, isOverflow);
            this.configType = autocompleteConfigType;
            this.functionFullName = functionFullName;
            this.functionReverseFullName = functionReverseFullName;
        }
    }

}