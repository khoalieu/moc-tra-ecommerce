package model;

import java.io.Serializable;

public class RevenueDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    private String label;
    private double revenue;

    public RevenueDTO() {}

    public String getLabel() {
        return label;
    }

    public void setLabel(String label) {
        this.label = label;
    }

    public double getRevenue() {
        return revenue;
    }

    public void setRevenue(double revenue) {
        this.revenue = revenue;
    }
}
