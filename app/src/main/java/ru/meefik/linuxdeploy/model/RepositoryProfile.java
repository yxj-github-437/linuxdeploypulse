package ru.meefik.linuxdeploy.model;

public class RepositoryProfile {
    private String url;
    private String description;
    private String type;
    private String ExtractionCode;
    private int iconId;

    public RepositoryProfile(String type,int iconId) {
        this.iconId = iconId;
        this.type = type;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String geturl() {
        return url;
    }

    public void seturl(String url) {
        this.url = url;
    }

    public void setinonId(int Id) {this.iconId = Id;}

    public int getIconId() {return this.iconId;}

    public void setExtractionCode(String code) {this.ExtractionCode = code;}

    public String getExtractionCode() {return this.ExtractionCode;}

}
