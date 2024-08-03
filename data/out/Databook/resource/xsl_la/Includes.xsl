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

  <!-- load configuration xml -->
  <xsl:variable name="Config"  select="document('../../config.xml')/config"/>
  <xsl:variable name="MapNode" select="$Config/mapping"/>
  
  <xsl:variable name="Extensions" select="document('../../extensions.xml')/Extensions"/>
  
  <!-- use Html or PDF in type to switch between styles -->
  <xsl:variable name="type"><xsl:value-of select="$Config/@style"/></xsl:variable>
  
  <!-- use PDF in DocType to generate PDF -->
  <xsl:variable name="DocType"><xsl:value-of select="$Config/@doctype"/></xsl:variable>
  
  <!-- Global variables: used to locate/process fixed sections -->
  <xsl:variable name="AbsDeviation"  select="$Config/mapping/entry[@key='AbsDeviation']/@value"/>
  <xsl:variable name="DevMode"       select="'deviation'"/>
  <xsl:variable name="GroupedMode"   select="'grouped'"/>
  <xsl:variable name="DevModeAbs"    select="'deviation_abs'"/>
  <xsl:variable name="DevModeBest"   select="'best'"/>
  <xsl:variable name="DevModeWorst"  select="'worst'"/>
  <xsl:variable name="FocusCorr"     select="'correlation'"/>
  <xsl:variable name="FOOS"          select="'FOOS'"/>
  <xsl:variable name="FOPD"          select="'FOPD'"/>
  <xsl:variable name="FP"            select="'FP'"/>
  <xsl:variable name="MS"            select="'MS'"/>
  <xsl:variable name="NoCorner"      select="$Config/mapping/entry[@key='NoCorner']/@value"/>
  <xsl:variable name="OS"            select="'OS'"/>
  <xsl:variable name="MP"            select="'MP'"/>
  <xsl:variable name="OSRatio"       select="'OSRatio'"/>
  <xsl:variable name="PDV"           select="'PDV'"/>
  <xsl:variable name="PD"            select="'PD'"/>
  <xsl:variable name="PDRatio"       select="'PDRatio'"/>
  <xsl:variable name="PWR"           select="'PWR'"/>
  <xsl:variable name="TP"            select="'TP'"/>
  <xsl:variable name="TPF"           select="'TPF'"/>
  <xsl:variable name="TPR"           select="'TPR'"/>
  <xsl:variable name="RP"            select="'RP'"/>
  <xsl:variable name="RRMS"          select="'RRMS'"/>
  <xsl:variable name="DQ"            select="'DQ'"/>
  <xsl:variable name="ST"            select="'ST'"/>
  <xsl:variable name="HT"            select="'HT'"/>
  <xsl:variable name="RC"            select="'RC'"/>
  <xsl:variable name="RM"            select="'RM'"/>
  <xsl:variable name="DPO"           select="'DPO'"/>
  <xsl:variable name="TPO"           select="'TPO'"/>
  <xsl:variable name="PO"            select="'PO'"/>
  <xsl:variable name="GP"            select="'GP'"/>
  <xsl:variable name="MPW"           select="'MPW'"/>
  <xsl:variable name="FO4D"          select="'FO4D'"/>
  <xsl:variable name="QOR"           select="'QOR'"/>
  <xsl:variable name="MXC"           select="'MXC'"/>
  <xsl:variable name="CTV"           select="'CTV'"/>
  <xsl:variable name="RelDeviation"  select="$Config/mapping/entry[@key='RelDeviation']/@value"/>
  <xsl:variable name="GroupSuffix"   select="$Config/mapping/entry[@key='GroupSuffix']/@value"/>
  <xsl:variable name="XmlCornerList" select="document('../../CornerList.xml')"/>
  <xsl:variable name="XmlLibrary"    select="document(concat('../../', /*/@LibFile,/Library/FileName))"/>
  <xsl:variable name="CAP"           select="'CAP'"/>
  <xsl:variable name="CCSCap"        select="'CCSCap'"/>
  <xsl:variable name="ECSMCap"       select="'ECSMCap'"/>
  <xsl:variable name="SP"            select="'SP'"/>
  <xsl:variable name="LC"            select="'LC'"/>
  <xsl:variable name="PAR"           select="'PAR'"/>
  <xsl:variable name="FCP"           select="'FCP'"/>
  <xsl:variable name="FCD"           select="'FCD'"/>
  <xsl:variable name="TFCP"          select="'TFCP'"/>

  <xsl:variable name="Corner"     select="/*/@CornerName"/>
  <xsl:variable name="CornerNode" select="$XmlCornerList/CornerList/Corner[@Name=$Corner]"/>
  <xsl:variable name="RefNode"    select="$XmlCornerList/CornerList/Corner[@Id=$CornerNode/@Ref]"/>
  <xsl:variable name="TrgNode"    select="$XmlCornerList/CornerList/Corner[@Id=$CornerNode/Trg/@Id[position()=1]]"/>
  <xsl:variable name="RefXmlLib"  select="document($RefNode/@File)/Library"/>

  <xsl:variable name="invalid_pushout_thr" select="-9999"/>
  <xsl:variable name="invalid_pushout"     select="'&#216;'"/>

  <xsl:variable name="constr_valid_no_data_thr" select="-8999"/>
  <xsl:variable name="constr_valid_no_data"     select="'N.A.'"/>

  <xsl:variable name="LibMode">
    
    <xsl:variable name="GroupedLib">
      <xsl:choose>
        <xsl:when test="$GroupSuffix = substring($Corner, string-length($Corner) - string-length($GroupSuffix)+1)">y</xsl:when>
        <xsl:otherwise>n</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:choose>
      <xsl:when test="$CornerNode/@Type='abs'">
        <xsl:value-of select="$DevModeAbs"/>
      </xsl:when>
      <xsl:when test="$CornerNode/@Type='rel' and $GroupedLib = 'n'">
        <xsl:value-of select="$DevMode"/>
      </xsl:when>
      <xsl:when test="$CornerNode/@Type='rel' and $GroupedLib = 'y'">
        <xsl:value-of select="$GroupedMode"/>
      </xsl:when>
      <xsl:when test="$CornerNode/@Type='best'">
        <xsl:value-of select="$DevModeBest"/>
      </xsl:when>
      <xsl:when test="$CornerNode/@Type='worst'">
        <xsl:value-of select="$DevModeWorst"/>
      </xsl:when>
      <xsl:otherwise>normal</xsl:otherwise>
    </xsl:choose>
    
  </xsl:variable>
  
  <xsl:variable name="RootPath">
    <xsl:choose>
      <xsl:when test="/Cell">..</xsl:when>
      <xsl:when test="/Profilings">..</xsl:when>
      <xsl:otherwise>.</xsl:otherwise>
    </xsl:choose>
  </xsl:variable> 

  <xsl:variable name="isCellPage"><xsl:if test="/Cell">true</xsl:if></xsl:variable>

  <xsl:variable name="UnitNode" select="$Config/units[@type=$LibMode]"/>
  
  <xsl:variable name="unit" select="$Config/unit"/>
  
  <xsl:variable name="match">"MATCH"</xsl:variable>
  <xsl:variable name="diff">"DIFF"</xsl:variable>
  
  <!-- Add the stylesheets (basic and databook specific) according to $type and javascripts -->
  <xd:doc>
    <xd:short>Adds the stylesheets to the current document, according to the style specified in <i>config.xml</i>.</xd:short>
    <xd:param name="dir" type="string">specifies the current working directory</xd:param>
  </xd:doc>
  <xsl:template name="Includes">
    
    <xsl:param name="dir">.</xsl:param>
    
    <xsl:if test="$DocType!='PDF'">
      
      <link>
        <xsl:attribute name="rel">stylesheet</xsl:attribute>
        <xsl:attribute name="type">text/css</xsl:attribute>
        <xsl:attribute name="href"><xsl:value-of select="$dir"/>/resource/css/Databook.css</xsl:attribute>
      </link>
      
      <script type="text/javascript">
        var openImg = "<xsl:value-of select="$dir"/>/resource/image/open_square.gif";
        var closeImg = "<xsl:value-of select="$dir"/>/resource/image/close_square.gif";
      </script>
      <script type="text/javascript">
        <xsl:attribute name="src"><xsl:value-of select="$dir"/>/resource/js/main.js</xsl:attribute>
      </script>
      <script>
        function hidestatus(){
        window.status='';
        return true;
        }
        document.onmouseover=hidestatus;
        document.onmouseout=hidestatus;
      </script>
     
    </xsl:if>
    
  </xsl:template>


  <!-- Unit Formatting Utility -->
  <xd:doc>
    Main unit formatting template. Receives as parameter a numeric value and formats it to the outut.
    <xd:param name="value" type="double">value to be formatted</xd:param>
    <xd:param name="pattern" type="string">optional parameter. May be used to specify a pattern (such as "0.000") under which the value must be formatted</xd:param>
  </xd:doc>
  <xsl:template name="FormatUnit">
    <xsl:param name="value"/>
    <xsl:param name="pattern">0.00</xsl:param>
    <xsl:choose>
      <xsl:when test="contains(concat('',number($value)),'NaN')"><xsl:value-of select="$value"/></xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="format-number($value, $pattern)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Unit Labeling Utility -->
  <xd:doc>
    Writes the label of an unit
    <xd:param name="label" type="string">original unit label</xd:param>
  </xd:doc>
  <xsl:template name="LabelUnit">
    <xsl:param name="label"/>
    <xsl:choose>
      <xsl:when test="$CornerNode/@Type='rel'">[%]</xsl:when>
      <xsl:otherwise><xsl:value-of select="$label"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>
                                          

</xsl:stylesheet>
