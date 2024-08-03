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
  
  <xsl:include href="NavigationBar.xsl"/>
  <xsl:include href="TimingTable.xsl"/> 

  <!-- QoR table processment -->
  <xd:doc>Redirects QoR and Max Cap data to be processed by the proper template</xd:doc>
  <xsl:template match="ConstraintValidation">
    <xsl:call-template name="BuildTable"/>
  </xsl:template>
  
  
  <!-- Table processment -->
  <xd:doc>Builds the table page. Calls the appropriate templates to build each section of the page</xd:doc>
  <xsl:template name="BuildTable">
    
    <xsl:variable name="Title">
      <xsl:call-template name="Map">
        <xsl:with-param name="map" select="$MapNode/summary"/>
        <xsl:with-param name="key" select="concat(@Name,'_Title')"/>
      </xsl:call-template>
    </xsl:variable>
    
    <html>
      <head>
        <title>
          <xsl:value-of select="$Title"/>
        </title>
        <xsl:call-template name="Includes"/>
      </head>
      <body onLoad="NanInit();">

        <a id="PageInfo">
          <xsl:attribute name="RootPath"><xsl:value-of select="$RootPath"/></xsl:attribute>
          <xsl:attribute name="CellPath"><xsl:value-of select="'Cells/'"/></xsl:attribute>
          <xsl:attribute name="SummName"><xsl:value-of select="/*/@Name"/></xsl:attribute>
          <xsl:attribute name="Corner"><xsl:value-of select="$Corner"/></xsl:attribute>
          <xsl:attribute name="RefNode"><xsl:value-of select="$RefNode/@Name"/></xsl:attribute>
          <xsl:attribute name="TrgNode"><xsl:value-of select="$TrgNode/@Name"/></xsl:attribute>
          <xsl:attribute name="FileExt"><xsl:value-of select="$Extensions/Cell"/></xsl:attribute>
        </a>

        
        <xsl:call-template name="SilvacoHeader">
          <xsl:with-param name="dir"   select="'.'"/>
          <xsl:with-param name="Title"  select="$Title"/>
        </xsl:call-template>

        <!-- Top navigation links -->
        <xsl:call-template name="AutoBuildNavigationBar">
          
          <xsl:with-param name="PrevName">
            <xsl:if test="Navigation/Previous">
              <xsl:call-template name="Map">
                <xsl:with-param name="map" select="$MapNode/summary"/>
                <xsl:with-param name="key" select="concat(Navigation/Previous/@Name,'_Title')"/>
              </xsl:call-template>
            </xsl:if>
          </xsl:with-param>
          
          <xsl:with-param name="NextName">
            <xsl:if test="Navigation/Next">
              <xsl:call-template name="Map">
                <xsl:with-param name="map" select="$MapNode/summary"/>
                <xsl:with-param name="key" select="concat(Navigation/Next/@Name,'_Title')"/>
              </xsl:call-template>
            </xsl:if>
          </xsl:with-param>
          
        </xsl:call-template>
        
        <xsl:call-template name="TitleNotesConstrValid"/>

        <xsl:call-template name="GenTablesConstrValid"/>
        <xsl:call-template name="NotesConstrValid"/>
        
        <!-- Bottom navigation links -->
        <xsl:call-template name="AutoBuildNavigationBar">
          
          <xsl:with-param name="Pos">Bottom</xsl:with-param>
          
          <xsl:with-param name="PrevName">
            <xsl:if test="Navigation/Previous">
              <xsl:call-template name="Map">
                <xsl:with-param name="map" select="$MapNode/summary"/>
                <xsl:with-param name="key" select="concat(Navigation/Previous/@Name,'_Title')"/>
              </xsl:call-template>
            </xsl:if>
          </xsl:with-param>
          
          <xsl:with-param name="NextName">
            <xsl:if test="Navigation/Next">
              <xsl:call-template name="Map">
                <xsl:with-param name="map" select="$MapNode/summary"/>
                <xsl:with-param name="key" select="concat(Navigation/Next/@Name,'_Title')"/>
              </xsl:call-template>
            </xsl:if>
          </xsl:with-param>
          
        </xsl:call-template>       
       
      </body>
    </html>
    
  </xsl:template>
  
  
  <!-- Generate summary table itself -->
  <xsl:template name="GenTablesConstrValid">

    <xsl:for-each select="Table">
    <a>
        
      <xsl:attribute name="name">
        <xsl:value-of select="concat('Table_',@Id)"/>
      </xsl:attribute>
      
      <xsl:call-template name="CreateTableCaption"/>        
      <span>         
        <xsl:attribute name="id">
          <xsl:value-of select="concat('_Table_',@Id)"/>
        </xsl:attribute>
        <xsl:call-template name="CreateConstrValidTable"/>
      </span>

    </a>
    </xsl:for-each>

  </xsl:template>


  <xd:doc>
    Builds the QoR Table
  </xd:doc>
  <xsl:template name="CreateConstrValidTable">

    <hr class="Title"/>
    <div>
      <xsl:attribute name="ngTable">ConstrValidSumm</xsl:attribute>
      <xsl:attribute name="constrValidSumm"><xsl:value-of select="@name"/></xsl:attribute>
      <xsl:attribute name="label"><xsl:value-of select="$timLabel"/></xsl:attribute>
      <xsl:variable name="entries">
        <xsl:for-each select="Cell">
          <xsl:value-of select="@name"/>;
          <xsl:for-each select="Entry">
            <xsl:value-of select="@type"/>;
            <xsl:choose>
              <xsl:when test="abs/@avg = $invalid_pushout_thr">
                <xsl:value-of select="$invalid_pushout"/>
              </xsl:when>
              <xsl:when test="abs/@avg = $constr_valid_no_data_thr">
                <xsl:value-of select="$constr_valid_no_data"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="FormatUnit">
                  <xsl:with-param name="value" select="abs/@avg"/>
                  </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>;
            <xsl:choose>
              <xsl:when test="abs/@ratio = $invalid_pushout_thr">
                <xsl:value-of select="$invalid_pushout"/>
              </xsl:when>
              <xsl:when test="abs/@ratio = $constr_valid_no_data_thr">
                <xsl:value-of select="$constr_valid_no_data"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="FormatUnit">
                  <xsl:with-param name="value" select="abs/@ratio"/>
                  </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>;
            <xsl:choose>
              <xsl:when test="rel/@avg = $invalid_pushout_thr">
                <xsl:value-of select="$invalid_pushout"/>
              </xsl:when>
              <xsl:when test="rel/@avg = $constr_valid_no_data_thr">
                <xsl:value-of select="$constr_valid_no_data"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="FormatUnit">
                  <xsl:with-param name="value" select="rel/@avg"/>
                  </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>;
            <xsl:choose>
              <xsl:when test="rel/@ratio = $invalid_pushout_thr">
                <xsl:value-of select="$invalid_pushout"/>
              </xsl:when>
              <xsl:when test="rel/@ratio = $constr_valid_no_data_thr">
                <xsl:value-of select="$constr_valid_no_data"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="FormatUnit">
                  <xsl:with-param name="value" select="rel/@ratio"/>
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>;
          </xsl:for-each>$
        </xsl:for-each>
      </xsl:variable>
      <xsl:attribute name="entries"><xsl:value-of select="translate(normalize-space($entries),' ','')"/></xsl:attribute>
    </div>
    <hr class="Title"/>
  </xsl:template>
  
  <!-- Helper for generating title notes in summary tables -->
  <xd:doc>Generates the informations that appear at the title of the page</xd:doc>
  <xsl:template name="TitleNotesConstrValid">
    
    <xsl:variable name="Page">ConstraintValidation</xsl:variable>
    
    <xsl:call-template name="CreateTitleCornerNote">
      <xsl:with-param name="Page" select="$Page"/>
    </xsl:call-template>

    <p>See <a href="#Notes">notes</a> for additional information.</p>
    
  </xsl:template>
    
  
  <!-- Generate notes -->
  <xd:doc>Generates the informations that appear at the bottom of the page</xd:doc>
  <xsl:template name="NotesConstrValid">
    <a name="Notes">
      <xsl:call-template name="CreateCollapse">
        <xsl:with-param name="name">Notes</xsl:with-param>
        <xsl:with-param name="dir">.</xsl:with-param>
      </xsl:call-template>
      
      <span id="_Notes">
        <ul>
          <xsl:variable name="Page">ConstraintValidation</xsl:variable>

          <li>
            <xsl:call-template name="BasicNotes">
              <xsl:with-param name="Page"       select="$Page"/>
            </xsl:call-template>
          </li>
          
          <li>
            <xsl:call-template name="Corner">
              <xsl:with-param name="Page"    select="$Page"/>
            </xsl:call-template>
          </li>
        </ul>
      </span>
    </a>
  </xsl:template>
  
</xsl:stylesheet>
