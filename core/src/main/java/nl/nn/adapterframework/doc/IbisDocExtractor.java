package nl.nn.adapterframework.doc;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.*;

public class IbisDocExtractor {

    private ArrayList<AFolder> folders = new ArrayList<AFolder>();
    private ArrayList<AClass> classes = new ArrayList<AClass>();
    private String json = "";

    public void writeToJsonUrl() {
        JSONArray newFolders = new JSONArray();
        JSONArray newClasses;
        JSONArray newMethods;

        try {
            for (AFolder folder : folders) {
                JSONObject folderObject = new JSONObject();
                folderObject.put("name", folder.name);

                newClasses = new JSONArray();
                for (AClass aClass : folder.getClasses()) {
                    JSONObject classObject = new JSONObject();
                    classObject.put("name", aClass.name);
                    classObject.put("packageName", aClass.packageName);

                    newMethods = new JSONArray();
                    for (AMethod method : aClass.getMethods()) {
                        JSONObject methodObject = new JSONObject();
                        methodObject.put("name", method.name);
                        methodObject.put("description", method.description);
                        methodObject.put("defaultValue", method.defaultValue);
                        methodObject.put("className", method.className);
                        methodObject.put("folderName", method.folderName);
                        methodObject.put("originalClassName", method.originalClassName);
                        methodObject.put("superClasses", method.superClasses);
                        methodObject.put("javadocLink", method.javadocLink);
                        methodObject.put("order",  method.order);
                        newMethods.put(methodObject);

                    }
                    classObject.put("methods", newMethods);
                    newClasses.put(classObject);
                }
                folderObject.put("classes", newClasses);
                newFolders.put(folderObject);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }

        json = newFolders.toString();
    }

    public String getJsonString() {
        return this.json;
    }

    public void addAllFolder() {
        AFolder allFolder = new AFolder("All");
        for (AFolder folder : folders) {
            for (AClass clazz : folder.getClasses()) {
                allFolder.addClass(clazz);
            }
        }
        folders.add(allFolder);
    }

    public void addMethods(String currentFolder, String currentClass, String packageName, String methodName, String description, String defaultValue, String originalClassName, ArrayList<String> superClasses, String javadocLink, int order) {

        // Check if the folder already exists (there is only one of each)
        boolean folderExists = false;
        for (AFolder folder : folders) {
            if (currentFolder.equals(folder.getName())) {
                folderExists = true;
                break;
            }
        }

        if (!folderExists) {
            folders.add(new AFolder(currentFolder));
        }

        // Check if the class already exists (We assume there is only one of each)
        boolean classExists = false;
        for (AClass aClass : classes) {
            if (currentClass.equals(aClass.getName())) {
                classExists = true;
                break;
            }
        }

        if (!classExists) {
            for (AFolder folder : folders) {
                if (currentFolder.equals(folder.getName())) {
                    folder.addClass(new AClass(currentClass, packageName));
                    classes.add(new AClass(currentClass, packageName));
                }
            }
        }

        for (AFolder folder : folders) {
            if (currentFolder.equals(folder.getName())) {
                for (AClass aClass : folder.getClasses()) {
                    if (currentClass.equals(aClass.getName())) {
                        aClass.addMethod(new AMethod(currentFolder, currentClass, methodName, description, defaultValue, originalClassName, superClasses, javadocLink, order));
                    }
                }
            }
        }

    }

    class AMethod {

        private String name;
        private String description;
        private String defaultValue;
        private String className;
        private String packageName;
        private String folderName;
        private String originalClassName;
        private ArrayList<String> superClasses;
        private String javadocLink;
        private int order;

        public AMethod(String folderName, String className, String name, String description, String defaultValue, String originalClassName, ArrayList<String> superClasses, String javadocLink, int order) {
            this.folderName = folderName;
            this.className = className;
            this.name = name;
            this.description = description;
            this.defaultValue = defaultValue;
            this.originalClassName = originalClassName;
            this.superClasses = superClasses;
            this.javadocLink = javadocLink;
            this.order = order;
        }
    }

    class AClass {
        private String name;
        private String packageName;
        private ArrayList<AMethod> methods;

        public AClass(String name, String packageName) {
            this.name = name;
            this.packageName = packageName;
            this.methods = new ArrayList<AMethod>();
        }

        public String getName() {
            return this.name;
        }

        public void addMethod(AMethod method) {
            this.methods.add(method);
        }

        public ArrayList<AMethod> getMethods() {
            return this.methods;
        }
    }

    class AFolder {
        private String name;
        private ArrayList<AClass> classes;

        public AFolder(String name) {
            this.name = name;
            this.classes = new ArrayList<AClass>();
        }

        public String getName() {
            return name;
        }

        public void addClass(AClass clazz) {
            this.classes.add(clazz);
        }

        public ArrayList<AClass> getClasses() {
            return this.classes;
        }
    }
}
