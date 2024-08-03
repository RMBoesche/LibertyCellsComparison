<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xd="http://www.pnp-software.com/XSLTdoc">

  <!--
  Copyright (C) 1984-2024 Silvaco, Inc.                    
  All rights reserved.                            
                                                                             
  The Silvaco name and the Silvaco logo are trademarks of Silvaco, Inc.      
  and/or its affiliates ("Silvaco"). All trademarks, logos, software marks,  
  and trade names (collectively, the "Marks") in this program are            
  proprietary to Silvaco or other respective owners that have granted        
  Silvaco the right and license to use such Marks. You are not permitted to  
  use the Marks without the prior written consent of Silvaco or such third   
  party that may own the Marks.                                              
                                                                             
  This file has been provided pursuant to a license agreement containing     
  restrictions on its use. This file contains valuable trade secrets and     
  proprietary information of Silvaco and is protected by U.S. and            
  international laws.                                                        
                                                                             
  The copyright notice(s) in this file do not indicate actual or intended    
  publication of this file.                                                  
  -->

  <xsl:variable name="Path">../../</xsl:variable>
  <xsl:variable name="key"><xsl:value-of select="/*/@Name"/></xsl:variable>
  <xsl:variable name="templates"   select="document(concat($Path, 'Templates_',   $Corner, '.xml'))/Templates"/>
  <xsl:variable name="templates3d" select="document(concat($Path, '3DTemplates_', $Corner, '.xml'))/Templates"/>
  
  <xsl:variable name="file">
    <xsl:variable name="fileName">
      <xsl:choose>
        <xsl:when test="/*/@Name=$FOPD or /*/@Name=$PDRatio"><xsl:value-of select="$PD"/></xsl:when>
        <xsl:when test="/*/@Name=$FOOS or /*/@Name=$OSRatio"><xsl:value-of select="$OS"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="/*/@Name"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:call-template name="Map">
      <xsl:with-param name="key" select="concat($fileName, '_Tag')"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="SrcFile_Ref" select="'%DIFF%'"/>

  <xsl:variable name="SumB1"><xsl:if test="$CornerNode/@Ref and 
                                           ($key=$OS or $key=$PD or $key=$FCD or $key=$OSRatio or $key=$PDRatio or $key=$SP or $key=$MP or
                                            $key=$FP or $key=$RP or $key=$PWR or $key=$FCP or $key=$TFCP or $key=$MS or $key=$RRMS or $key=$DQ or
                                            $key=$ST or $key=$HT or $key=$RC or $key=$RM or $key=$FO4D)">y</xsl:if></xsl:variable>
  <xsl:variable name="SumB2"><xsl:if test="$SumB1='y' and not (/*/@AnalysisFocus=$FocusCorr) and not ($LibMode=$GroupedMode)">y</xsl:if></xsl:variable>

  <xsl:variable name="capLabel"><xsl:call-template name="LabelUnit"><xsl:with-param name="label" select="$unit/capacitance"/></xsl:call-template></xsl:variable>
  <xsl:variable name="curLabel"><xsl:call-template name="LabelUnit"><xsl:with-param name="label" select="$unit/current"/></xsl:call-template></xsl:variable>
  <xsl:variable name="dpLabel"><xsl:call-template name="LabelUnit"><xsl:with-param name="label" select="$unit/dyn_power"/></xsl:call-template></xsl:variable>
  <xsl:variable name="hpLabel"><xsl:call-template name="LabelUnit"><xsl:with-param name="label" select="$unit/hid_power"/></xsl:call-template></xsl:variable>
  <xsl:variable name="lpLabel"><xsl:call-template name="LabelUnit"><xsl:with-param name="label" select="$unit/leak_power"/></xsl:call-template></xsl:variable>
  <xsl:variable name="timLabel"><xsl:call-template name="LabelUnit"><xsl:with-param name="label" select="$unit/time"/></xsl:call-template></xsl:variable>
  <xsl:variable name="voltLabel"><xsl:call-template name="LabelUnit"><xsl:with-param name="label" select="$unit/volt"/></xsl:call-template></xsl:variable>
  <xsl:variable name="ratioLabel"><xsl:call-template name="LabelUnit"><xsl:with-param name="label" select="'[rise/fall]'"/></xsl:call-template></xsl:variable>

  <xd:doc> 
    Main (Wrapper) function to print timing tables (within a cell, not summary tables). 
    It basically defines few values and calls PrintTimingTable_Int. 
    <xd:param name="SecId" type="string">identifier for the section to be created.</xd:param>
    <xd:param name="table_rise" type="XMLNode">
      <xd:short>Rise table node.</xd:short>
      <xd:detail>The xml node containing the rise table.</xd:detail>
    </xd:param>
    <xd:param name="table_fall" type="XMLNode">
      <xd:short>Fall table node.</xd:short>
      <xd:detail>The xml node containing the fall table.</xd:detail>
    </xd:param>
    <xd:param name="var1_label" type="string">Unit label to template index 1</xd:param>
    <xd:param name="var2_label" type="string">Unit label to template index 2</xd:param>
    <xd:param name="var3_label" type="string">Unit label to template index 3</xd:param>
    <xd:param name="unit_label" type="string">Unit label to table values</xd:param>
    <xd:param name="table_label_fall" type="string">Label to be used in headers (2 first lines)</xd:param>
    <xd:param name="table_label_rise" type="string">Label to be used in headers (2 first lines)</xd:param>
  </xd:doc>
  <xsl:template name="PrintTimingTable">
    <xsl:param name="SecId"/>
    <xsl:param name="table_rise"/>
    <xsl:param name="table_fall"/>
    <xsl:param name="var1_label"/>
    <xsl:param name="var2_label"/>
    <xsl:param name="var3_label"/>
    <xsl:param name="unit_label"/>
    <xsl:param name="table_label_fall" select="'fall '"/>
    <xsl:param name="table_label_rise" select="'rise '"/>
    <xsl:param name="extraCtx" select="''"/>
    <xsl:param name="constrValid" select="''"/>

    <xsl:choose>
      <!-- breaks down the table if templates are different -->
      <xsl:when test="$table_rise and $table_fall and $table_rise/LUT/@Template != $table_fall/LUT/@Template">
        
        <xsl:call-template name="PrintTableAttrs">
          <xsl:with-param name="table_rise"       select="null"/>
          <xsl:with-param name="table_fall"       select="$table_fall"/>
          <xsl:with-param name="var1_label"       select="$var1_label"/>
          <xsl:with-param name="var2_label"       select="$var2_label"/>
          <xsl:with-param name="var3_label"       select="$var3_label"/>
          <xsl:with-param name="unit_label"       select="$unit_label"/>
          <xsl:with-param name="table_label_fall" select="$table_label_fall"/>
          <xsl:with-param name="table_label_rise" select="$table_label_rise"/>
          <xsl:with-param name="SecId"            select="$SecId"/>
          <xsl:with-param name="extraCtx"         select="$extraCtx"/>
          <xsl:with-param name="constrValid"      select="$constrValid"/>
        </xsl:call-template>
        
        <xsl:call-template name="PrintTableAttrs">
          <xsl:with-param name="table_rise"       select="$table_rise"/>
          <xsl:with-param name="table_fall"       select="null"/>
          <xsl:with-param name="var1_label"       select="$var1_label"/>
          <xsl:with-param name="var2_label"       select="$var2_label"/>
          <xsl:with-param name="var3_label"       select="$var3_label"/>
          <xsl:with-param name="unit_label"       select="$unit_label"/>
          <xsl:with-param name="table_label_fall" select="$table_label_fall"/>
          <xsl:with-param name="table_label_rise" select="$table_label_rise"/>
          <xsl:with-param name="SecId"            select="$SecId"/>
          <xsl:with-param name="extraCtx"         select="$extraCtx"/>
          <xsl:with-param name="constrValid"      select="$constrValid"/>
        </xsl:call-template>
        
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="PrintTableAttrs">
          <xsl:with-param name="table_rise"       select="$table_rise"/>
          <xsl:with-param name="table_fall"       select="$table_fall"/>
          <xsl:with-param name="var1_label"       select="$var1_label"/>
          <xsl:with-param name="var2_label"       select="$var2_label"/>
          <xsl:with-param name="var3_label"       select="$var3_label"/>
          <xsl:with-param name="unit_label"       select="$unit_label"/>
          <xsl:with-param name="table_label_fall" select="$table_label_fall"/>
          <xsl:with-param name="table_label_rise" select="$table_label_rise"/>
          <xsl:with-param name="SecId"            select="$SecId"/>
          <xsl:with-param name="extraCtx"         select="$extraCtx"/>
          <xsl:with-param name="constrValid"      select="$constrValid"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>    
  </xsl:template>

  <!-- ********************************************** -->
  <xsl:template name="PrintHiddenPwrAttrs">
    <xsl:param name="var1_label"/>
    <xsl:param name="unit_label"/>
    <xsl:if test="HiddenPowerList/HiddenPowerEntry">
      <xsl:for-each select="HiddenPowerList/HiddenPowerEntry">
        <xsl:variable name="tableCount">
          <xsl:value-of select="count(HiddenLUT)"/>
        </xsl:variable>
        <div>
          <xsl:attribute name="ngTable">hidGr</xsl:attribute>
          <xsl:attribute name="hidGr"><xsl:value-of select="$tableCount"/></xsl:attribute>
          <xsl:attribute name="arc"><xsl:value-of select="../../@Name"/></xsl:attribute>
          <xsl:attribute name="i1">
            <xsl:call-template name="CreateTempIndex">
              <xsl:with-param name="index" select="Template/variable_1"/>
              <xsl:with-param name="label" select="$var1_label"/>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:for-each select="HiddenLUT">
            <div>
              <xsl:attribute name="desc"><xsl:value-of select="@descr"/></xsl:attribute>
              <xsl:call-template name="CreateTable">
                <xsl:with-param name="table"       select="LUT"/>
                <xsl:with-param name="tableLabel"  select="''"/>
                <xsl:with-param name="unitLabel"   select="$unit_label"/>
              </xsl:call-template>
            </div>
          </xsl:for-each>
        </div>
      </xsl:for-each>
    </xsl:if>    
  </xsl:template>
  
  <!-- ********************************************** -->
  <xsl:template name="PrintTableAttrs">
    <xsl:param name="SecId"/>
    <xsl:param name="table_rise"/>
    <xsl:param name="table_fall"/>
    <xsl:param name="table_label_rise"/>
    <xsl:param name="table_label_fall"/>
    <xsl:param name="var1_label"/>
    <xsl:param name="var2_label"/>
    <xsl:param name="var3_label"/>
    <xsl:param name="unit_label"/>
    <xsl:param name="extraCtx"/>
    <xsl:param name="constrValid" select="''"/>

    <xsl:if test="$table_fall/LUT | $table_rise/LUT">
      <xsl:variable name="tableCount">
        <xsl:choose>
          <xsl:when test="$table_fall/LUT and $table_rise/LUT">2</xsl:when>
          <xsl:otherwise>1</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <div>
        <xsl:attribute name="ngTable">tGr</xsl:attribute>
        <xsl:attribute name="tGr"><xsl:value-of select="$tableCount"/></xsl:attribute>
        <xsl:attribute name="ctx"><xsl:value-of select="concat(@RelatedPin,';',@TimingSense,';',@When,';',@SdfCond,';',@TimingType,';',@RelBusPin,';',@PgPin,';',@RelOutPin,';',@InterdepId,';',@PctThr,';',$extraCtx)"/></xsl:attribute>
        <xsl:variable name="hasFallTable" select="boolean($table_fall/LUT)"/>
        <xsl:variable name="refTable" select="$table_fall[$hasFallTable] | $table_rise[not($hasFallTable)]"/>
        <xsl:if test="$refTable/Template/variable_1">
          <xsl:variable name="concatTempIndex">
            <xsl:choose>
              <xsl:when test="$SecId=$RM or $SecId=$RC or $SecId=$RRMS"><xsl:value-of select="'RecRem_'"/></xsl:when>
              <xsl:otherwise/>
            </xsl:choose>
          </xsl:variable>
          <xsl:attribute name="i1">
            <xsl:call-template name="CreateTempIndex">
              <xsl:with-param name="index"         select="$refTable/Template/variable_1"/>
              <xsl:with-param name="label"         select="$var1_label"/>
              <xsl:with-param name="concatToName"  select="$concatTempIndex"/>
            </xsl:call-template>
          </xsl:attribute>
        </xsl:if>
        <xsl:if test="$refTable/Template/variable_2">
          <xsl:attribute name="i2">
            <xsl:call-template name="CreateTempIndex">
              <xsl:with-param name="index" select="$refTable/Template/variable_2"/>
              <xsl:with-param name="label" select="$var2_label"/>
            </xsl:call-template>
          </xsl:attribute>
        </xsl:if>
        <xsl:if test="$refTable/Template/variable_3">
          <xsl:attribute name="i3">
            <xsl:call-template name="CreateTempIndex">
              <xsl:with-param name="index" select="$refTable/Template/variable_3"/>
              <xsl:with-param name="label" select="$var3_label"/>
            </xsl:call-template>
          </xsl:attribute>
        </xsl:if>
        <xsl:attribute name="arc">
          <xsl:call-template name="CreateRelatedPinStr">
            <xsl:with-param name="table" select="$refTable"/>
          </xsl:call-template>
        </xsl:attribute>
     
        <xsl:if test="$table_fall/LUT">
          <div>
            <xsl:call-template name="CreateTable">
              <xsl:with-param name="table"        select="$table_fall/LUT"/>
              <xsl:with-param name="tableLabel"   select="$table_label_fall"/>
              <xsl:with-param name="unitLabel"    select="$unit_label"/>
              <xsl:with-param name="constrValid"  select="$constrValid"/>
            </xsl:call-template>
          </div>
        </xsl:if>
        <xsl:if test="$table_rise/LUT">
          <div>
            <xsl:call-template name="CreateTable">
              <xsl:with-param name="table"        select="$table_rise/LUT"/>
              <xsl:with-param name="tableLabel"   select="$table_label_rise"/>
              <xsl:with-param name="unitLabel"    select="$unit_label"/>
              <xsl:with-param name="constrValid"  select="$constrValid"/>
            </xsl:call-template>
          </div>
        </xsl:if>
      </div>
    </xsl:if>
  </xsl:template>

  <!-- ********************************************** -->
  <xsl:template name="CreateTable">
    <xsl:param name="SecId"/>
    <xsl:param name="table"/>
    <xsl:param name="unitLabel"/>
    <xsl:param name="tableLabel"/>
    <xsl:param name="addElems" select="'y'"/>
    <xsl:param name="statistics" select="$table/.."/>
    <xsl:param name="constrValid" select="''"/>

    <xsl:attribute name="t"><xsl:value-of select="concat($tableLabel,$unitLabel)"/></xsl:attribute>
    <xsl:attribute name="id"><xsl:value-of select="$table/@gid"/></xsl:attribute>
    <xsl:if test="$table/@rid">
      <xsl:attribute name="rid"><xsl:value-of select="$table/@rid"/></xsl:attribute>
    </xsl:if>
    <xsl:if test="$table/@tid">
      <xsl:attribute name="tid"><xsl:value-of select="$table/@tid"/></xsl:attribute>
    </xsl:if>
    <xsl:if test="Src/@LUT">
      <xsl:variable name="trace">
        <xsl:for-each select="Src"><xsl:value-of select="@LUT"/>#</xsl:for-each>
      </xsl:variable>
      <xsl:attribute name="trace"><xsl:value-of select="$trace"/></xsl:attribute>
    </xsl:if>
    <xsl:if test="$table/@Plot">
      <xsl:attribute name="p"><xsl:value-of select="$table/@Plot"/></xsl:attribute>
    </xsl:if>
    <xsl:if test="$table/@WavePlotRoot">
      <xsl:attribute name="wpr"><xsl:value-of select="$table/@WavePlotRoot"/></xsl:attribute>
    </xsl:if>
    <xsl:if test="$table/@WavePlot">
      <xsl:attribute name="wp"><xsl:value-of select="$table/@WavePlot"/></xsl:attribute>
    </xsl:if>
    <xsl:if test="$table/@VoltWavePlot">
      <xsl:attribute name="vwp"><xsl:value-of select="$table/@VoltWavePlot"/></xsl:attribute>
    </xsl:if>
    <xsl:if test="$table/@EcsmWavePlot">
      <xsl:attribute name="ewp"><xsl:value-of select="$table/@EcsmWavePlot"/></xsl:attribute>
    </xsl:if>
    <xsl:if test="$table/@WavePlotCount">
      <xsl:attribute name="wpc"><xsl:value-of select="$table/@WavePlotCount"/></xsl:attribute>
    </xsl:if>
    <xsl:if test="$statistics/@Avg">
      <xsl:attribute name="st">
        <xsl:call-template name="FormatUnit">
          <xsl:with-param name="value" select="$statistics/@Worst"/>
          </xsl:call-template><xsl:if test="@WorstTol='down'">d</xsl:if><xsl:if test="@WorstTol='up'">u</xsl:if>;<xsl:choose>
          <xsl:when test="$constrValid != '' and $statistics/@Avg = $invalid_pushout_thr"><xsl:value-of select="$invalid_pushout"/></xsl:when>
          <xsl:when test="$constrValid != '' and $statistics/@Avg = $constr_valid_no_data_thr"><xsl:value-of select="$constr_valid_no_data"/></xsl:when>
          <xsl:otherwise><xsl:call-template name="FormatUnit">
          <xsl:with-param name="value" select="$statistics/@Avg"/>
          </xsl:call-template><xsl:if test="@AvgTol='down'">d</xsl:if><xsl:if test="@AvgTol='up'">u</xsl:if></xsl:otherwise></xsl:choose>;<xsl:call-template name="FormatUnit">
          <xsl:with-param name="value" select="$statistics/@AbsAvg"/>
          </xsl:call-template><xsl:if test="@AbsAvgTol='down'">d</xsl:if><xsl:if test="@AbsAvgTol='up'">u</xsl:if>;<xsl:choose>
          <xsl:when test="$constrValid != '' and $statistics/@Avg = $invalid_pushout_thr"><xsl:value-of select="$invalid_pushout"/></xsl:when>
          <xsl:when test="$constrValid != '' and $statistics/@Avg = $constr_valid_no_data_thr"><xsl:value-of select="$constr_valid_no_data"/></xsl:when>
          <xsl:otherwise><xsl:call-template name="FormatUnit">
          <xsl:with-param name="value" select="$statistics/@Std_Dev"/>
          </xsl:call-template><xsl:if test="@StdDevTol='down'">d</xsl:if><xsl:if test="@StdDevTol='up'">u</xsl:if></xsl:otherwise></xsl:choose>;<xsl:call-template name="FormatUnit">
          <xsl:with-param name="value" select="$statistics/@RMS"/>
          </xsl:call-template><xsl:if test="@RMSTol='down'">d</xsl:if><xsl:if test="@RMSTol='up'">u</xsl:if>;<xsl:call-template name="FormatUnit">
          <xsl:with-param name="value" select="$statistics/@Best"/>
          </xsl:call-template><xsl:if test="@BestTol='down'">d</xsl:if><xsl:if test="@BestTol='up'">u</xsl:if>;<xsl:choose>
          <xsl:when test="@StdDev_Avg_Ratio!='-'"><xsl:call-template name="FormatUnit">
            <xsl:with-param name="value" select="$statistics/@StdDev_Avg_Ratio"/>
          </xsl:call-template>
          </xsl:when>
          <xsl:otherwise><xsl:value-of select="@StdDev_Avg_Ratio"/></xsl:otherwise>
          </xsl:choose>
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="$addElems!='n'">
      <xsl:variable name="values">
        <xsl:for-each select="$table/Line/El">
          <xsl:choose>
            <xsl:when test="$constrValid != '' and @Value = $invalid_pushout_thr">
              <xsl:value-of select="$invalid_pushout"/>
            </xsl:when>
            <xsl:when test="$constrValid != '' and @Value = $constr_valid_no_data_thr">
              <xsl:value-of select="$constr_valid_no_data"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="FormatUnit">
                <xsl:with-param name="value" select="@Value"/>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:if test="@cValidNomDelay='yes'">n</xsl:if><xsl:if test="@cValidNomSlew='yes'">t</xsl:if><xsl:if test="@cValidStepOver='yes'">s</xsl:if>
          <xsl:if test="@cValidWindow='yes'">w</xsl:if><xsl:if test="@cValidDiscarded='yes'">x</xsl:if>
          <xsl:if test="@interp='yes'">i</xsl:if><xsl:if test="@tolExceeded='down'">d</xsl:if><xsl:if test="@tolExceeded='up'">u</xsl:if>
          <xsl:if test="@Plot">$<xsl:value-of select="@Plot"/></xsl:if>
          <xsl:if test="Src/@LUT">
            <xsl:for-each select="Src">
              #<xsl:value-of select="@LUT"/><xsl:if test="@Line">_<xsl:value-of select="@Line"/>_<xsl:value-of select="@Elem"/></xsl:if>
            </xsl:for-each>
            </xsl:if>;
        </xsl:for-each>
      </xsl:variable>
      <xsl:attribute name="el"><xsl:value-of select="translate(normalize-space($values),' ','')"/></xsl:attribute>
    </xsl:if>
  </xsl:template>
 
  <!-- ********************************************** -->
  <xsl:template name="CreateTempIndex">
    <xsl:param name="index"/>
    <xsl:param name="label"/>
    <xsl:param name="concatToName" select="''"></xsl:param>
    <xsl:variable name="values">
      <xsl:for-each select="$index/Values/El">
        <xsl:call-template name="FormatUnit">
          <xsl:with-param name="pattern"   select="'0.00##'"/>
          <xsl:with-param name="value"     select="@Value"/>
        </xsl:call-template>;</xsl:for-each>
    </xsl:variable>
    <xsl:variable name="tempIndexName">
      <xsl:value-of select="translate(normalize-space(concat($concatToName,$index/Name)),' ','')"/>
    </xsl:variable>
    <xsl:variable name="indexName">
      <xsl:call-template name="Map">
        <xsl:with-param name="map" select="$MapNode/TableHeader"/>
        <xsl:with-param name="key" select="$tempIndexName"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:value-of select="concat($indexName,';',$label,';',$values)"/>
  </xsl:template>


  <!-- ********************************************** -->
  <xsl:template name="PrintTimingTable_Aglomerated">
    
    <xsl:param name="table"/>
    <xsl:param name="SecId"/>
    <xsl:param name="var1_label"/>
    <xsl:param name="var2_label"/>
    <xsl:param name="unit_label"/>
    <xsl:param name="sub_link"/>
    <xsl:param name="table_label">
      <xsl:value-of select="$unit_label"/>
    </xsl:param>
    
    <xsl:if test="$table/LUT">

      <xsl:choose>
        <xsl:when test="/*/@Name=$MP or /*/@Name=$SP or /*/@Name=$CAP or /*/@Name=$FOPD or /*/@Name=$FOOS or /*/@Name=$FO4D">
          <xsl:variable name="value_pattern">
            <xsl:choose>
              <xsl:when test="/*/@Name=$CAP">0.0000</xsl:when>
              <xsl:otherwise>0.00</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:for-each select="$table/LUT[not(preceding-sibling::LUT/@Template = @Template)]">
            <!-- selects all LUTs with the same template, thus grouping by template -->
            <xsl:variable name="Temp" select="@Template"/>
            <xsl:choose>
              <xsl:when test="$Temp='scalar'">
                <!-- Scalar -->
                <div>
                  <xsl:attribute name="ngTable">sumSc</xsl:attribute>
                  <xsl:attribute name="sumSc"><xsl:value-of select="count($table/LUT[@Template=$Temp])"/></xsl:attribute>
                  <xsl:variable name="entries">
                    <xsl:for-each select="$table/LUT[@Template=$Temp]">
                      <xsl:variable name="value">
                        <xsl:call-template name="FormatUnit">
                          <xsl:with-param name="value"    select="Line/El/@Value"/>
                          <xsl:with-param name="pattern"  select="$value_pattern"/>
                          </xsl:call-template><xsl:if test="Line/El/@interp='yes'">i</xsl:if><xsl:if test="Line/El/@tolExceeded='down'">d</xsl:if><xsl:if test="Line/El/@tolExceeded='up'">u</xsl:if>
                      </xsl:variable>
                      <xsl:value-of select="concat(@id,';',$table_label,';',$value,';',Line/El/Src/@LUT,';$')"/>
                    </xsl:for-each>
                  </xsl:variable>
                  <xsl:attribute name="entries"><xsl:value-of select="normalize-space($entries)"/></xsl:attribute>
                </div>
              </xsl:when>
              <xsl:when test="(/FirstOrder)">
                <!-- 1D -->
                <xsl:for-each select="$templates/Template[@Name = $Temp]">
                  <div>
                    <xsl:attribute name="ngTable">stApp</xsl:attribute>
                    <xsl:attribute name="stApp"><xsl:value-of select="$SecId"/></xsl:attribute>
                    <xsl:if test="variable_1">
                      <xsl:attribute name="i1">
                        <xsl:call-template name="CreateTempIndex">
                          <xsl:with-param name="index" select="variable_1"/>
                          <xsl:with-param name="label" select="$var1_label"/>
                        </xsl:call-template>
                      </xsl:attribute>
                    </xsl:if>
                    <xsl:for-each select="$table/LUT[@Template = $Temp]">
                      <div>
                        <xsl:attribute name="t"><xsl:value-of select="./@id"/></xsl:attribute>
                        <xsl:attribute name="id"><xsl:value-of select="./@id"/><xsl:value-of select="../@Id"/></xsl:attribute>
                        <xsl:attribute name="unit"><xsl:value-of select="$unit_label"/></xsl:attribute>
                        <xsl:attribute name="trace"><xsl:value-of select="Src/@LUT"/></xsl:attribute>
                        <xsl:variable name="values">
                          <xsl:for-each select="LinApprox/Line">
                            <xsl:variable name="ca">
                              <xsl:call-template name="FormatUnit">
                                <xsl:with-param name="value" select="@cAng"/>
                              </xsl:call-template>
                            </xsl:variable>
                            <xsl:variable name="cl">
                              <xsl:call-template name="FormatUnit">
                                <xsl:with-param name="value" select="@cLin"/>
                              </xsl:call-template>
                            </xsl:variable>
                            <xsl:value-of select="concat($ca,'$',$cl,';')"/>
                          </xsl:for-each>                    
                        </xsl:variable>
                        <xsl:attribute name="el"><xsl:value-of select="$values"/></xsl:attribute>
                      </div>
                    </xsl:for-each>
                  </div>
                </xsl:for-each>
              </xsl:when>
              <xsl:otherwise>
                <!-- FO4 -->
                <xsl:for-each select="$templates/Template[@Name = $Temp]">
                  <div>
                    <xsl:attribute name="ngTable">sumGr</xsl:attribute>
                    <xsl:attribute name="sumGr"><xsl:value-of select="$SecId"/></xsl:attribute>
                    <xsl:if test="variable_1">
                      <xsl:attribute name="i1">
                        <xsl:call-template name="CreateTempIndex">
                          <xsl:with-param name="index" select="variable_1"/>
                          <xsl:with-param name="label" select="$var1_label"/>
                        </xsl:call-template>
                      </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="variable_2">
                      <xsl:attribute name="i2">
                        <xsl:call-template name="CreateTempIndex">
                          <xsl:with-param name="index" select="variable_2"/>
                          <xsl:with-param name="label" select="$var2_label"/>
                        </xsl:call-template>
                      </xsl:attribute>
                    </xsl:if>
                    <xsl:for-each select="$table/LUT[@Template = $Temp]">
                      <div>
                        <xsl:attribute name="unit"><xsl:value-of select="$unit_label"/></xsl:attribute>
                        <xsl:call-template name="CreateTable">
                          <xsl:with-param name="table"       select="."/>
                          <xsl:with-param name="tableLabel"  select="./@id"/>
                          <xsl:with-param name="unitLabel"   select="''"/>
                        </xsl:call-template>
                      </div>
                    </xsl:for-each>
                  </div>
                </xsl:for-each>
              </xsl:otherwise>
            </xsl:choose>        
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <!-- 2D -->
          <div>
            <xsl:attribute name="ngTable">sumSt</xsl:attribute>
            <xsl:attribute name="sumSt"><xsl:value-of select="$SecId"/></xsl:attribute>
            <xsl:for-each select="$table/LUT">
              <div>
                <xsl:attribute name="unit"><xsl:value-of select="$unit_label"/></xsl:attribute>
                <xsl:if test="Template/variable_1">
                  <xsl:variable name="concatTempIndex">
                    <xsl:choose>
                      <xsl:when test="$SecId=$RM or $SecId=$RC or $SecId=$RRMS"><xsl:value-of select="'RecRem_'"/></xsl:when>
                      <xsl:otherwise/>
                    </xsl:choose>
                  </xsl:variable>
                  <xsl:attribute name="i1">
                    <xsl:call-template name="CreateTempIndex">
                      <xsl:with-param name="index" select="Template/variable_1"/>
                      <xsl:with-param name="label" select="$var1_label"/>
                      <xsl:with-param name="concatToName"  select="$concatTempIndex"/>                      
                    </xsl:call-template>
                  </xsl:attribute>
                </xsl:if>
                <xsl:if test="Template/variable_2">
                  <xsl:attribute name="i2">
                    <xsl:call-template name="CreateTempIndex">
                      <xsl:with-param name="index" select="Template/variable_2"/>
                      <xsl:with-param name="label" select="$var2_label"/>
                    </xsl:call-template>
                  </xsl:attribute>
                </xsl:if>
                <xsl:call-template name="CreateTable">
                  <xsl:with-param name="table"       select="."/>
                  <xsl:with-param name="tableLabel"  select="./@id"/>
                  <xsl:with-param name="unitLabel"   select="''"/>
                  <xsl:with-param name="statistics"  select="."/>
                </xsl:call-template>
              </div>
            </xsl:for-each>
          </div>
        </xsl:otherwise>
      </xsl:choose>
      <hr class="Title"/>      
    </xsl:if>   
  </xsl:template>
  
  <!-- ********************************************** --> 
  <xsl:template name="CreateRelatedPinStr">
    <xsl:param name="table"/>
    <xsl:choose>
      <xsl:when test="(name($table)='fall_power' or name($table)='rise_power' or name($table)='power') and name($table/parent::*/parent::*) = 'HiddenPowerList'">Pin <xsl:value-of select="$table/../../../@Name"/></xsl:when>
      <xsl:when test="$table/../@RelatedPin and (name($table)='fall_transition' or name($table)='cell_fall' or name($table)='rise_transition' or name($table)='cell_rise' or name($table)='fall_power' or name($table)='rise_power' or name($table)='power')"><xsl:value-of select="$table/../@RelatedPin"/> to <xsl:value-of select="$table/../../../@Name"/></xsl:when>
      <xsl:when test="$table/../@RelatedPin and (name($table)='receiver_capacitance1_fall' or name($table)='receiver_capacitance1_rise')"><xsl:value-of select="$table/../@RelatedPin"/> to <xsl:value-of select="$table/../../../@Name"/>  [C1]</xsl:when>
      <xsl:when test="$table/../@RelatedPin and (name($table)='receiver_capacitance2_fall' or name($table)='receiver_capacitance2_rise')"><xsl:value-of select="$table/../@RelatedPin"/> to <xsl:value-of select="$table/../../../@Name"/>  [C2]</xsl:when>
      <xsl:when test="$table/../@RelatedPin"><xsl:value-of select="$table/../@RelatedPin"/> to <xsl:value-of select="$table/../../../@Name"/></xsl:when>
      <xsl:when test="(name($table)='fall_power_1D' or name($table)='rise_power_1D' or name($table)='power_1D') and $table/../@Name"><xsl:value-of select="$table/../@Name"/></xsl:when>
      <xsl:when test="(name($table)='receiver_capacitance1_fall' or name($table)='receiver_capacitance1_rise') and name($table/parent::*) = 'RecCap'">Pin <xsl:value-of select="$table/../../../@Name"/> [C1]</xsl:when>
      <xsl:when test="(name($table)='receiver_capacitance2_fall' or name($table)='receiver_capacitance2_rise') and name($table/parent::*) = 'RecCap'">Pin <xsl:value-of select="$table/../../../@Name"/> [C2]</xsl:when>
      <xsl:when test="(name($table)='receiver_capacitance_rise') and name($table/parent::*) = 'Pin'">Pin <xsl:value-of select="$table/../@Name"/></xsl:when>
      <xsl:when test="(name($table)='ecsm_capacitance') and name($table/parent::*/parent::*/parent::*) = 'Pin'">Pin <xsl:value-of select="$table/../../../@Name"/></xsl:when>
      <xsl:when test="(name($table)='ecsm_capacitance') and $table/../../../@RelatedPin"><xsl:value-of select="$table/../../../@RelatedPin"/> to <xsl:value-of select="$table/../../../../../@Name"/></xsl:when>
      <xsl:when test="(name($table)='ConstrainedDataToOutputDelayFall' or name($table)='ConstrainedDataToOutputDelayRise') and translate(normalize-space($table/../direction),'&quot;','')='output'">data to <xsl:value-of select="$table/../@Name"/></xsl:when>
      <xsl:when test="(name($table)='ConstrainedDataToOutputDelayFall' or name($table)='ConstrainedDataToOutputDelayRise')">data to output</xsl:when>
      <xsl:when test="name($table)='MetastabilityWindowSHHigh' or name($table)='MetastabilityWindowSHLow' or name($table)='MetastabilityWindowRRHigh' or name($table)='MetastabilityWindowRRLow'"><xsl:value-of select="$table/../@Name"/> (<xsl:value-of select="$table/LUT/@id"/>)</xsl:when>
      <xsl:when test="$table/../@Name"><xsl:value-of select="$table/../@Name"/> to <xsl:value-of select="$table/LUT/@id"/></xsl:when>
    </xsl:choose>
  </xsl:template>
  
  
  <!-- ********************************************** -->
  <xsl:template name="FillOneValue">
    <xsl:param name="Text"/>    
    <td class="num">
      <xsl:call-template name="negative">
         <xsl:with-param name="text" select="$Text"/>
       </xsl:call-template>
      <div>
        <xsl:call-template name="exceeded">
          <xsl:with-param name="text"     select="$Text"/>
          <xsl:with-param name="exceeded" select="@tolExceeded"/>
          <xsl:with-param name="interpolation" select="@interp"/>
        </xsl:call-template> 
      </div>
    </td>    
  </xsl:template>
   
  <!-- ********************************************** -->
  <xd:doc> Helper to create table headers.
    <xd:param name="var_name_1"     type="string">Name of the first template variable.</xd:param>
    <xd:param name="var_name_2"     type="string">Name of the second template variable.</xd:param>
    <xd:param name="ignore_v2"      type="char">y/n used to ignore the second variable.</xd:param>
    <xd:param name="header_colspan" type="integer">number of columns to be occupied by the variable names (two by default)</xd:param>
    <xd:param name="reduced_title"  type="string">Extra title for reduced tables</xd:param>
  </xd:doc>
  <xsl:template name="BuildTableHeader">
    <xsl:param name="var_name_1"/>
    <xsl:param name="var_name_2"/>
    <xsl:param name="ignore_v2"/>
    <xsl:param name="header_colspan">2</xsl:param>
    <xsl:param name="reduced_title"></xsl:param>
    <xsl:param name="reduced_link"></xsl:param>
    <!-- count values to create colspan properly -->
    <xsl:variable name="Var1Count">
      <xsl:choose>
        <xsl:when test="variable_1">
          <xsl:value-of select="count(variable_1/Values/El)"/>
        </xsl:when>
        <xsl:otherwise>1</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="Var2Count">
      <xsl:choose>
        <xsl:when test="variable_2 and $ignore_v2='n'">
          <xsl:value-of select="count(variable_2/Values/El)"/>
        </xsl:when>
        <xsl:otherwise>1</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>   
    <colgroup>
      <col/><col/>
      <xsl:for-each select="variable_1/Values/El">
        <xsl:choose>
          <xsl:when test="$ignore_v2='y'">
            <col/>
          </xsl:when>
          <xsl:when test="$ignore_v2='n'">
            <xsl:for-each select="../../../variable_2/Values/El">
              <col/>
            </xsl:for-each>
          </xsl:when>
        </xsl:choose>
      </xsl:for-each>
    </colgroup>   
    <thead>
      <xsl:if test="$reduced_title != ''">
        <tr>
          <th class="reduced_title">
            <xsl:attribute name="colspan">
              <xsl:value-of select="$header_colspan + $Var1Count*$Var2Count"/>
            </xsl:attribute>
              <a>
                <xsl:if test="$reduced_link != ''">
                  <xsl:attribute name="href"><xsl:value-of select="$reduced_link"/></xsl:attribute>
                </xsl:if>
                <xsl:value-of select="$reduced_title"/>
              </a>
          </th>
        </tr>
      </xsl:if>
      <!-- create header (first 2 lines of the tables), base on template values -->
      <tr>
        <xsl:element name="th">
          <xsl:attribute name="colspan">
            <xsl:value-of select="$header_colspan"/>
          </xsl:attribute>
          <xsl:value-of select="$var_name_1"/>
        </xsl:element>
        <xsl:for-each select="variable_1/Values/El">
          <xsl:element name="th">
            <xsl:attribute name="colspan">
              <xsl:value-of select="$Var2Count"/>
            </xsl:attribute>
            <!-- Create highlight to the entire column -->
            <xsl:if test="($ignore_v2='y') or not(../../../variable_2)">
              <xsl:attribute name="onclick">cHL(this);</xsl:attribute>
            </xsl:if>
            <xsl:call-template name="FormatUnit">
              <xsl:with-param name="pattern"   select="'0.00##'"/>
              <xsl:with-param name="value"     select="@Value"/>
            </xsl:call-template>
          </xsl:element>
        </xsl:for-each>
        
      </tr>
      <!-- create second variable if existent and not ignored -->
      <xsl:if test="variable_2 and $ignore_v2='n'">
        <tr>
          <xsl:element name="th">
            <xsl:attribute name="colspan">
              <xsl:value-of select="$header_colspan"/>
            </xsl:attribute>
            <xsl:value-of select="$var_name_2"/>
          </xsl:element>
          <xsl:for-each select="variable_1/Values/El">
            <xsl:for-each select="../../../variable_2/Values/El">
              <th>
                <xsl:attribute name="onclick">cHL(this);</xsl:attribute>
                <xsl:call-template name="FormatUnit">
                  <xsl:with-param name="pattern"   select="'0.00##'"/>
                  <xsl:with-param name="value"     select="@Value"/>
                </xsl:call-template>
              </th>
            </xsl:for-each>
          </xsl:for-each>
        </tr>
      </xsl:if>
    </thead>
  </xsl:template>
 

  <!-- ********************************************** -->
  <xd:doc> Builds the Char Enviroment Table </xd:doc>
  <xsl:template name="CreateCharEnvTable">
    <xsl:param name="dir">.</xsl:param>
    <hr class="Title"/>
      <xsl:for-each select="El">
        <a>
          <xsl:attribute name="name">
            <xsl:value-of select="@Name"/>
          </xsl:attribute>
        <xsl:call-template name="CreateCollapse">
          <xsl:with-param name="name" select="@Name"/>
          <xsl:with-param name="dir" select = "$dir"/>
        </xsl:call-template>
        <span>
          <xsl:attribute name="id"><xsl:value-of select="concat('_', @Name)"/></xsl:attribute>
        <div>
          <xsl:attribute name="ngTable">CharEnv</xsl:attribute>
          <xsl:variable name="entries">
            <xsl:for-each select="entry">         
              <xsl:value-of select="@name"/>;
              <xsl:value-of select="."/>$
            </xsl:for-each>
          </xsl:variable>
          <xsl:attribute name="entries"><xsl:value-of select="translate(normalize-space($entries),'','')"/></xsl:attribute>
        </div>
      </span>
        </a>
      </xsl:for-each>
  </xsl:template>


  <!-- ********************************************** -->
  <xd:doc>Creates timing arc reduced tables
    <xd:param name="arcRedNode"   type="XMLNode">Node where the arc reductions are stored</xd:param>
    <xd:param name="type"         type="String">the type of the table (currently, power|timing|constraint|cap)</xd:param>
  </xd:doc>
  <xsl:template name="PrintArcRedTable">
    <xsl:param name="arcRedNode"/>
    <xsl:param name="type"/>
    <xsl:choose>
      
      <xsl:when test="$type='leakage'">
        <table border="1" class="reduced">
          <tr colspan="2"><th class="reduced_title">
            <a>
              <xsl:attribute name="href">#StaticPowerConsumption</xsl:attribute>
              Leakage <xsl:value-of select="$lpLabel"/>
            </a>
          </th></tr>
          <xsl:if test="cell_leakage_power">
            <tr colspan="2">
              <xsl:call-template name="FillOneValue">
                <xsl:with-param name="Text">
                  <xsl:call-template name="FormatUnit">
                    <xsl:with-param name="value"     select="cell_leakage_power"/>
                  </xsl:call-template>
                </xsl:with-param>            
              </xsl:call-template>
            </tr>
          </xsl:if>
         <!-- not yet available in xml files
          <xsl:if test="min_leakage">
            <tr>
              <th>min</th>
              <xsl:call-template name="FillOneValue">
                <xsl:with-param name="Text">
                  <xsl:call-template name="FormatUnit">
                    <xsl:with-param name="value"     select="min_leakage"/>
                  </xsl:call-template>
                </xsl:with-param>            
              </xsl:call-template>
            </tr>
          </xsl:if>
          <xsl:if test="max_leakage">
            <tr>
              <th>max</th>
              <xsl:call-template name="FillOneValue">
                <xsl:with-param name="Text">
                  <xsl:call-template name="FormatUnit">
                    <xsl:with-param name="value"     select="max_leakage"/>
                  </xsl:call-template>
                </xsl:with-param>            
              </xsl:call-template>
            </tr>
          </xsl:if>                  
         -->
        </table>
      </xsl:when>

      <xsl:when test="$type='power'">
        <xsl:variable name="printInput">
          <xsl:choose>
            <xsl:when test="ArcReductions/InputPowerEntry/OutputPin/InputPower/Fall/LUT | ArcReductions/InputPowerEntry/OutputPin/InputPower/Rise/LUT | ArcReductions/InputPowerEntry/OutputPin/InputPower/Power/LUT">y</xsl:when>
            <xsl:otherwise>n</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="printDynamic">
          <xsl:choose>
            <xsl:when test="ArcReductions/PowerEntry/OutputPin/Power/Fall/LUT | ArcReductions/PowerEntry/OutputPin/Power/Rise/LUT | ArcReductions/PowerEntry/OutputPin/Power/Power/LUT">y</xsl:when>
            <xsl:otherwise>n</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:if test="$printDynamic='y' or $printInput='y'">
          <table class="reduced">
            <tr>
              <xsl:if test="$printInput='y'">
                <td valign="top">
                  <xsl:call-template name="PowerRedTable">
                    <xsl:with-param name="TableType" select="'InputPower'"/>
                    <xsl:with-param name="PowerRedNode" select="$arcRedNode/InputPowerEntry/OutputPin/InputPower"/>
                    <xsl:with-param name="id" select="'HP'"/>
                    <xsl:with-param name="unit_label" select="$hpLabel"/>
                  </xsl:call-template>
                </td>
              </xsl:if>
            
              <xsl:if test="$printDynamic='y' and $printInput='y'">
                <td width="5%"></td>
              </xsl:if>

              <xsl:if test="$printDynamic='y'">
                <td valign="top">
                  <xsl:call-template name="PowerRedTable">
                    <xsl:with-param name="TableType" select="'Power'"/>
                    <xsl:with-param name="PowerRedNode" select="$arcRedNode/PowerEntry/OutputPin/Power"/>
                    <xsl:with-param name="id" select="'DP'"/>
                    <xsl:with-param name="unit_label" select="$dpLabel"/>
                  </xsl:call-template>
                </td>
              </xsl:if>
            </tr>
          </table>
        </xsl:if>
      </xsl:when>

      <xsl:when test="$type='timing'">
        <xsl:variable name="tempName">
          <xsl:choose>
            <xsl:when test="ArcReductions/TimingEntry/OutputPin/Delay/Fall/LUT">
              <xsl:value-of select="ArcReductions/TimingEntry/OutputPin/Delay/Fall/LUT/@Template"/>
            </xsl:when>
            <xsl:when test="ArcReductions/TimingEntry/OutputPin/Delay/Rise/LUT">
              <xsl:value-of select="ArcReductions/TimingEntry/OutputPin/Delay/Rise/LUT/@Template"/>
            </xsl:when>
            <xsl:when test="ArcReductions/TimingEntry/OutputPin/Trans/Fall/LUT">
              <xsl:value-of select="ArcReductions/TimingEntry/OutputPin/Trans/Fall/LUT/@Template"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="ArcReductions/TimingEntry/OutputPin/Trans/Rise/LUT/@Template"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:variable name="printDelay">
          <xsl:choose>
            <xsl:when test="ArcReductions/TimingEntry/OutputPin/Delay/Fall/LUT | ArcReductions/TimingEntry/OutputPin/Delay/Rise/LUT">y</xsl:when>
            <xsl:otherwise>n</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="printTrans">
          <xsl:choose>
            <xsl:when test="ArcReductions/TimingEntry/OutputPin/Trans/Fall/LUT | ArcReductions/TimingEntry/OutputPin/Trans/Rise/LUT">y</xsl:when>
            <xsl:otherwise>n</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        
        <xsl:for-each select="$templates/Template[@Name = $tempName]">
          
          <!-- build table header (2 first lines) -->
          <xsl:variable name="var_name_1">
            <xsl:call-template name="Map">
              <xsl:with-param name="map" select="$MapNode/TableHeader"/>
              <xsl:with-param name="key" select="variable_1/Name"/>
            </xsl:call-template>
            <xsl:value-of select="concat(' ',$unit/time)"/>
          </xsl:variable>

          <xsl:variable name="var_name_2">
            <xsl:call-template name="Map">
              <xsl:with-param name="map" select="$MapNode/TableHeader"/>
              <xsl:with-param name="key" select="variable_2/Name"/>
            </xsl:call-template>
            <xsl:value-of select="concat(' ',$unit/capacitance)"/>
          </xsl:variable>

          <table class="reduced">
            <tr>
              <td valign="top">
                <xsl:if test="$printDelay='y'">
                  <xsl:call-template name="CreateInnerRedTable">
                    <xsl:with-param name="SecId"      select="'PD'"/>
                    <xsl:with-param name="unit_label" select="$timLabel"/>
                    <xsl:with-param name="dataNode"   select="$arcRedNode/TimingEntry/OutputPin/Delay"/>
                    <xsl:with-param name="var_name_1" select="$var_name_1"/>
                    <xsl:with-param name="var_name_2" select="$var_name_2"/>
                  </xsl:call-template>
                </xsl:if>
              </td>
              <td width="5%"></td>
              <td valign="top">
                <xsl:if test="$printTrans='y'">
                  <xsl:call-template name="CreateInnerRedTable">
                    <xsl:with-param name="SecId"      select="'OS'"/>
                    <xsl:with-param name="unit_label" select="$timLabel"/>
                    <xsl:with-param name="dataNode"   select="$arcRedNode/TimingEntry/OutputPin/Trans"/>
                    <xsl:with-param name="var_name_1" select="$var_name_1"/>
                    <xsl:with-param name="var_name_2" select="$var_name_2"/>
                  </xsl:call-template>
                </xsl:if>
              </td>
            </tr>
          </table>        
        </xsl:for-each>
      </xsl:when>

      <xsl:when test="$type='cap'">
        <xsl:if test="count($arcRedNode/Pin/capacitance)">
          <table border="1" class="reduced">
            <tr><th class="reduced_title" colspan="2">
            <a>
              <xsl:attribute name="href">#Capacitance</xsl:attribute>
              Capacitance <xsl:value-of select="$capLabel"/>
            </a>
            </th></tr>
            <xsl:for-each select="$arcRedNode/Pin/capacitance">           
              <tr>
                <th><xsl:value-of select="../@Name"/></th>
                <xsl:call-template name="FillOneValue">
                  <xsl:with-param name="Text">
                    <xsl:call-template name="FormatUnit">
                      <xsl:with-param name="value"     select="."/>
                      <xsl:with-param name="pattern"   select="'0.0000'"/>
                    </xsl:call-template>
                  </xsl:with-param>            
                </xsl:call-template>
              </tr>
            </xsl:for-each>
          </table>
        </xsl:if>
      </xsl:when>

      <xsl:otherwise>
        <table border="1" class="reduced">
          <tr><th class="reduced_title" colspan="3">
            <a>
              <xsl:attribute name="href">#Constraints</xsl:attribute>
              Constraints Time <xsl:value-of select="$timLabel"/>
            </a>
          </th></tr>
          <xsl:for-each select="$arcRedNode/ConstraintEntry">
            <xsl:for-each select="OutputPin">
              <xsl:for-each select="./Setup">
                <xsl:call-template name="FillReducedTable">
                  <xsl:with-param name="tableType" select="'Setup'"/>
                </xsl:call-template>
              </xsl:for-each>
              <xsl:for-each select="./Hold">
                <xsl:call-template name="FillReducedTable">
                  <xsl:with-param name="tableType" select="'Hold'"/>
                </xsl:call-template>
              </xsl:for-each>
              <xsl:for-each select="./Recovery">
              <xsl:call-template name="FillReducedTable">
                <xsl:with-param name="tableType" select="'Recovery'"/>
              </xsl:call-template>
              </xsl:for-each>
              <xsl:for-each select="./Removal">
                <xsl:call-template name="FillReducedTable">
                  <xsl:with-param name="tableType" select="'Removal'"/>
                </xsl:call-template>
              </xsl:for-each>
            </xsl:for-each>
          </xsl:for-each>
        </table>        
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ********************************************** -->
  <xd:doc>Prepares data to be written in arc reduced table
    <xd:param name="SecId"      type="String">Id of the table</xd:param>
    <xd:param name="dataNode"   type="XMLNode">Node pointing to the data</xd:param>
    <xd:param name="unit_label" type="XMLNode">Unit label</xd:param>
    <xd:param name="var_name_1" type="String">Name of the first template var</xd:param>
    <xd:param name="var_name_2" type="String">Name of the second template var</xd:param>
  </xd:doc>
  <xsl:template name="CreateInnerRedTable">
    <xsl:param name="SecId"/>
    <xsl:param name="dataNode"/>
    <xsl:param name="unit_label"/>
    <xsl:param name="var_name_1"/>
    <xsl:param name="var_name_2"/>
    <table border="1" class="inner">
      <xsl:variable name="SecTitle">
        <xsl:call-template name="Map">
          <xsl:with-param name="key" select="concat($SecId, '_Title')"/>
        </xsl:call-template>
        <xsl:text> </xsl:text>
        <xsl:value-of select="$unit_label"/>
      </xsl:variable>
      <xsl:variable name="SecLink">#<xsl:call-template name="Map">
        <xsl:with-param name="key" select="concat($SecId, '_Tag')"/>
      </xsl:call-template></xsl:variable>

      <xsl:variable name="Ignore">
        <xsl:choose>
          <xsl:when test="$var_name_2=''">
            <xsl:value-of select="'y'"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="'n'"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <!-- Prints 2D Lut's: print table header, 2 first columns -->
      <xsl:call-template name="BuildTableHeader">
        <xsl:with-param name="var_name_1"     select="$var_name_1"/>
        <xsl:with-param name="var_name_2"     select="$var_name_2"/>
        <xsl:with-param name="header_colspan" select="'2'"/>
        <xsl:with-param name="reduced_title"  select="$SecTitle"/>
        <xsl:with-param name="reduced_link"   select="$SecLink"/>
        <xsl:with-param name="ignore_v2"      select="$Ignore"/>
      </xsl:call-template>
      <!-- Print table content -->
      <xsl:for-each select="$dataNode">
        <xsl:call-template name="FillReducedTable"/>
      </xsl:for-each>
    </table>
  </xsl:template>
      
  <xd:doc>Prepares data to be written in arc reduced table
    <xd:param name="tableType"  type="String">Type of the displayed table</xd:param>
  </xd:doc>
  <xsl:template name="FillReducedTable">
    <xsl:param name="tableType"/>

    <xsl:variable name="rowCount">
      <xsl:value-of select="count(./*)"/>
    </xsl:variable>

    <xsl:if test="$rowCount > 0">
      <tr>
        <th><xsl:attribute name="rowspan"><xsl:value-of select="$rowCount"/></xsl:attribute>
          <xsl:choose>
            <xsl:when test="../../@name != ''">
              <xsl:value-of select="$tableType"/><xsl:text> </xsl:text><xsl:value-of select="../../@name"/> to <xsl:value-of select="../@name"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="../@name"/>
            </xsl:otherwise>
          </xsl:choose>
        </th>

        <xsl:choose>
          <xsl:when test="./Fall">
            <xsl:call-template name="FillReducedLine">
              <xsl:with-param name="SecLabel" select="'fall'"/>
              <xsl:with-param name="dataNode" select="./Fall"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="./Rise">
            <xsl:call-template name="FillReducedLine">
              <xsl:with-param name="SecLabel" select="'rise'"/>
              <xsl:with-param name="dataNode" select="./Rise"/>
            </xsl:call-template>
          </xsl:when>
          <!-- Power -->
          <xsl:otherwise>          
            <xsl:call-template name="FillReducedLine">
              <xsl:with-param name="SecLabel" select="'power'"/>
              <xsl:with-param name="dataNode" select="./Power"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </tr>
      
      <xsl:if test="$rowCount > 1">
        <tr>
          <xsl:choose>
            <xsl:when test="./Rise">
              <xsl:call-template name="FillReducedLine">
                <xsl:with-param name="SecLabel" select="'rise'"/>
                <xsl:with-param name="dataNode" select="./Rise"/>
              </xsl:call-template>
            </xsl:when>
            <!-- Power -->
            <xsl:otherwise>          
              <xsl:call-template name="FillReducedLine">
                <xsl:with-param name="SecLabel" select="'power'"/>
                <xsl:with-param name="dataNode" select="./Power"/>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
        </tr>
        <xsl:if test="$rowCount = 3">
          <tr>
            <xsl:call-template name="FillReducedLine">
              <xsl:with-param name="SecLabel" select="'power'"/>
              <xsl:with-param name="dataNode" select="./Power"/>
            </xsl:call-template>
          </tr>
        </xsl:if>
      </xsl:if>
    </xsl:if>
  </xsl:template>
    

  <xsl:template name="FillReducedLine">
    <xsl:param name="SecLabel"/>
    <xsl:param name="dataNode"/>
 
    <th><xsl:attribute name="onclick">rHL(this);</xsl:attribute><xsl:value-of select="$SecLabel"/></th>
    <xsl:choose>
      <xsl:when test="$dataNode/LUT">
        <xsl:for-each select="$dataNode/LUT">
          <xsl:call-template name="FillReducedValues"/>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="FillOneValue">
          <xsl:with-param name="Text">
            <xsl:call-template name="FormatUnit">
              <xsl:with-param name="value"     select="$dataNode"/>
            </xsl:call-template>
          </xsl:with-param>
          <xsl:with-param name="TolExceeded" select="$dataNode/@tolExceeded"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xd:doc>Prints arc reduced values to the table</xd:doc>
  <xsl:template name="FillReducedValues">
    <xsl:for-each select="Line">
      <xsl:for-each select="El">
        <xsl:call-template name="FillOneValue">
          <xsl:with-param name="Text">
            <xsl:call-template name="FormatUnit">
              <xsl:with-param name="value"     select="@Value"/>
            </xsl:call-template>
          </xsl:with-param>            
        </xsl:call-template>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>
 
  <!--Table type should be 'InputPower' or 'Power' -->
  <xsl:template name="PowerRedTable">
    <xsl:param name="TableType"/>
    <xsl:param name="PowerRedNode"/>
    <xsl:param name="id"/>
    <xsl:param name="unit_label"/>

    <xsl:variable name="tempName">
      <xsl:choose>
        <xsl:when test="$PowerRedNode/Fall/LUT">    
          <xsl:value-of select="$PowerRedNode/Fall/LUT/@Template"/>
        </xsl:when>
        <xsl:when test="$PowerRedNode/Rise/LUT">
          <xsl:value-of select="$PowerRedNode/Rise/LUT/@Template"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$PowerRedNode/Power/LUT/@Template"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:for-each select="$templates/Template[@Name = $tempName]">        
      <xsl:variable name="var_name_1">
        <xsl:call-template name="Map">
          <xsl:with-param name="map" select="$MapNode/TableHeader"/>
          <xsl:with-param name="key" select="variable_1/Name"/>
        </xsl:call-template>
        <xsl:value-of select="concat(' ',$unit/time)"/>
      </xsl:variable>

      <xsl:variable name="var_name_2">
        <xsl:choose>
          <xsl:when test="$TableType='Power'">
            <xsl:call-template name="Map">
              <xsl:with-param name="map" select="$MapNode/TableHeader"/>
              <xsl:with-param name="key" select="variable_2/Name"/>
            </xsl:call-template>
            <xsl:value-of select="concat(' ',$unit/capacitance)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="''"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <table style="margin-left:0">
        <tr>
          <td>
            <xsl:call-template name="CreateInnerRedTable">
              <xsl:with-param name="SecId"      select="$id"/>
              <xsl:with-param name="unit_label" select="$unit_label"/>
              <xsl:with-param name="dataNode"   select="$PowerRedNode"/>
              <xsl:with-param name="var_name_1" select="$var_name_1"/>
              <xsl:with-param name="var_name_2" select="$var_name_2"/>
            </xsl:call-template>
          </td>
        </tr>
      </table>          
    </xsl:for-each>
  </xsl:template>

  <!-- FillPushoutValue -->
  <xsl:template name="FillPushoutValue">
    <xsl:param name="valueNode"/>
    <xsl:choose>
      <xsl:when test="$valueNode">
        <xsl:choose>
          <xsl:when test="$valueNode/@Avg = $invalid_pushout_thr">
            <td class="num"><xsl:value-of select="$invalid_pushout"/></td>
            <td class="num"><xsl:value-of select="$invalid_pushout"/></td>
          </xsl:when>
          <xsl:when test="$valueNode/@Avg = $constr_valid_no_data_thr">
            <td class="num"><xsl:value-of select="$constr_valid_no_data"/></td>
            <td class="num"><xsl:value-of select="$constr_valid_no_data"/></td>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="FillOneValue">
              <xsl:with-param name="Text">
                <xsl:call-template name="FormatUnit">
                  <xsl:with-param name="value">
                    <xsl:value-of select="$valueNode/@Avg"/>
                  </xsl:with-param>
                </xsl:call-template>
              </xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="FillOneValue">
              <xsl:with-param name="Text">
                <xsl:call-template name="FormatUnit">
                  <xsl:with-param name="value">
                    <xsl:value-of select="$valueNode/@StdDev_Avg_Ratio"/>
                  </xsl:with-param>
                </xsl:call-template>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <td class="num">-</td>
        <td class="num">-</td>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- PrintPushoutSummary -->
  <xsl:template name="PrintPushoutSummary">
    <table border="1" class="reduced">
      <tr><th colspan="11" class="reduced_title">Constraint Validation</th></tr>
      <tr>
        <th rowspan="3"/>
        <th colspan="4"><a><xsl:attribute name="href">#PropagationDelayPushout</xsl:attribute>
        Propagation Delay</a></th>
        <th colspan="4"><a><xsl:attribute name="href">#OutputTransitionPushout</xsl:attribute>
        Output Transition</a></th>
        <th colspan="2" rowspan="2"><a><xsl:attribute name="href">#GlitchPeak</xsl:attribute>
        Glitch<br/>Peak [%]</a></th>
      </tr>
      <tr>
        <th colspan="2">Push-Out <xsl:value-of select="$timLabel"/></th><th colspan="2">Push-Out [%]</th>
        <th colspan="2">Push-Out <xsl:value-of select="$timLabel"/></th><th colspan="2">Push-Out [%]</th>
      </tr>
      <tr>
        <th title='Average'>&#956;</th><th title='Standard Deviation / Average'>&#963; / &#956;</th>
        <th title='Average'>&#956;</th><th title='Standard Deviation / Average'>&#963; / &#956;</th>
        <th title='Average'>&#956;</th><th title='Standard Deviation / Average'>&#963; / &#956;</th>
        <th title='Average'>&#956;</th><th title='Standard Deviation / Average'>&#963; / &#956;</th>
        <th title='Average'>&#956;</th><th title='Standard Deviation / Average'>&#963; / &#956;</th>
      </tr>
      <xsl:for-each select="ArcReductions/PushoutData/Entry">
        <tr>
          <th><xsl:value-of select="@name"/></th>
          <xsl:call-template name="FillPushoutValue">
            <xsl:with-param name="valueNode" select="delay/abs"/>
          </xsl:call-template>
          <xsl:call-template name="FillPushoutValue">
            <xsl:with-param name="valueNode" select="delay/rel"/>
          </xsl:call-template>
          <xsl:call-template name="FillPushoutValue">
            <xsl:with-param name="valueNode" select="transition/abs"/>
          </xsl:call-template>
          <xsl:call-template name="FillPushoutValue">
            <xsl:with-param name="valueNode" select="transition/rel"/>
          </xsl:call-template>
          <xsl:call-template name="FillPushoutValue">
            <xsl:with-param name="valueNode" select="glitch_peak/rel"/>
          </xsl:call-template>
        </tr>
      </xsl:for-each>
    </table>
  </xsl:template>

</xsl:stylesheet>
