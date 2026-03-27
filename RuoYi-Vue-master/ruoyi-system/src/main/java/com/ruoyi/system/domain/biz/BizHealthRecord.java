package com.ruoyi.system.domain.biz;

import com.ruoyi.common.core.domain.BaseEntity;
import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;

import java.math.BigDecimal;
import java.util.Date;

/**
 * 健康记录对象 biz_health_record
 */
public class BizHealthRecord extends BaseEntity {
    private static final long serialVersionUID = 1L;

    private Long recordId;

    private Long petId;

    private Date recordDate;

    private BigDecimal weightKg;

    private BigDecimal foodIntakeG;

    /** 排便状态：0正常 1异常 */
    private String defecationStatus;

    /** 精神状态：0良好 1一般 2萎靡 */
    private String mentalStatus;

    private String symptomDesc;

    private String isAbnormal;

    public Long getRecordId() {
        return recordId;
    }

    public void setRecordId(Long recordId) {
        this.recordId = recordId;
    }

    public Long getPetId() {
        return petId;
    }

    public void setPetId(Long petId) {
        this.petId = petId;
    }

    public Date getRecordDate() {
        return recordDate;
    }

    public void setRecordDate(Date recordDate) {
        this.recordDate = recordDate;
    }

    public BigDecimal getWeightKg() {
        return weightKg;
    }

    public void setWeightKg(BigDecimal weightKg) {
        this.weightKg = weightKg;
    }

    public BigDecimal getFoodIntakeG() {
        return foodIntakeG;
    }

    public void setFoodIntakeG(BigDecimal foodIntakeG) {
        this.foodIntakeG = foodIntakeG;
    }

    public String getDefecationStatus() {
        return defecationStatus;
    }

    public void setDefecationStatus(String defecationStatus) {
        this.defecationStatus = defecationStatus;
    }

    public String getMentalStatus() {
        return mentalStatus;
    }

    public void setMentalStatus(String mentalStatus) {
        this.mentalStatus = mentalStatus;
    }

    public String getSymptomDesc() {
        return symptomDesc;
    }

    public void setSymptomDesc(String symptomDesc) {
        this.symptomDesc = symptomDesc;
    }

    public String getIsAbnormal() {
        return isAbnormal;
    }

    public void setIsAbnormal(String isAbnormal) {
        this.isAbnormal = isAbnormal;
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this, ToStringStyle.MULTI_LINE_STYLE)
                .append("recordId", getRecordId())
                .append("petId", getPetId())
                .append("recordDate", getRecordDate())
                .append("weightKg", getWeightKg())
                .append("foodIntakeG", getFoodIntakeG())
                .append("defecationStatus", getDefecationStatus())
                .append("mentalStatus", getMentalStatus())
                .append("symptomDesc", getSymptomDesc())
                .append("isAbnormal", getIsAbnormal())
                .append("createBy", getCreateBy())
                .append("createTime", getCreateTime())
                .append("updateBy", getUpdateBy())
                .append("updateTime", getUpdateTime())
                .append("remark", getRemark())
                .toString();
    }
}
