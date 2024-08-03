<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xd="http://www.pnp-software.com/XSLTdoc" xmlns:fn="http://www.w3.org/2005/02/xpath-functions">
  
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

  <xsl:template name="SplitString">
    <xsl:param name="string"/>
    <xsl:param name="max_size"/>
    <xsl:param name="lin_pos"/>
    <xsl:param name="separator">_</xsl:param>

    <xsl:choose>
      <xsl:when test="contains(substring($string,number('0'), number($max_size)),' ')">

        <xsl:variable name="text" select="concat(substring-before($string,' '),' ')"/>
        <xsl:value-of select="$text"/>
        <xsl:call-template name="SplitString">
          <xsl:with-param name="string" select="substring($string,string-length($text)+1)"/>
          <xsl:with-param name="max_size" select="$max_size"/>
          <xsl:with-param name="lin_pos" select="'0'"/>
          <xsl:with-param name="separator" select="$separator"/>
        </xsl:call-template>

      </xsl:when>
      <xsl:otherwise>

        <xsl:choose>
          <xsl:when test="number($max_size) &lt; (string-length($string) + number($lin_pos))">
            <xsl:choose>
              <!-- contains separator inside max line size -->
              <xsl:when test="contains(substring($string,number('0'), number($max_size)),$separator)">

                <xsl:variable name="line" select="concat(substring-before($string,$separator),$separator)"/>

                <xsl:if test="string-length($line) + number($lin_pos) &gt;= number($max_size)">
                  <br/>
                </xsl:if>

                <xsl:variable name="new_lin_pos">
                  <xsl:choose>
                    <xsl:when test="string-length($line) + number($lin_pos) &gt;= number($max_size)">
                      <xsl:value-of select="'0'"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="$lin_pos"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:variable>

                <xsl:value-of select="$line"/>

                <xsl:call-template name="SplitString">
                  <xsl:with-param name="string" select="substring($string,string-length($line)+1)"/>
                  <xsl:with-param name="max_size" select="$max_size"/>
                  <xsl:with-param name="lin_pos" select="format-number(number($new_lin_pos) + string-length($line), '#')"/>
                  <xsl:with-param name="separator" select="$separator"/>
                </xsl:call-template>

              </xsl:when>

              <xsl:otherwise>

                <!-- simple split -->
                <xsl:variable name="line" select="substring($string,number('0'), number($max_size))"/>
            
                <xsl:if test="string-length($line) + number($lin_pos) &gt;= number($max_size)">
                  <br/>
                </xsl:if>
                <xsl:value-of select="$line"/>

                <xsl:if test="substring($string,string-length($line)+1) != ''">
                  <xsl:call-template name="SplitString">
                    <xsl:with-param name="string" select="substring($string,number($max_size))"/>
                    <xsl:with-param name="max_size" select="$max_size"/>
                    <xsl:with-param name="lin_pos" select="$max_size"/>
                    <xsl:with-param name="separator" select="$separator"/>
                  </xsl:call-template>
                </xsl:if>
              </xsl:otherwise>
            </xsl:choose>     
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$string"/>
          </xsl:otherwise>
        </xsl:choose>

      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>



  <xd:doc>
    Creates the notes section for the comparison pages
    <xd:param name="Page" type="string">name of the page for which the notes are being built</xd:param>
    <xd:param name="PDFLink" type="string">link to be used in the PDF version of the Databook</xd:param>
  </xd:doc>
  <xsl:template name="BasicNotes">
    
    <xsl:param name="Page" select="''"/>
    <xsl:param name="PDFLink"/>
    
    <xsl:if test="$CornerNode/@Ref">

      <xsl:if test="$Page!=''">
        This is 
          <xsl:choose>
            <xsl:when test="$LibMode=$DevModeAbs">an absolute</xsl:when>
            <xsl:when test="$LibMode=$DevModeBest">a best case</xsl:when>
            <xsl:when test="$LibMode=$DevModeWorst">a worst case</xsl:when>
              <xsl:when test="$LibMode=$DevMode and $Page='QoRMeasures'">the list of QoR measures retrieved from a relative</xsl:when>
            <xsl:otherwise>a relative</xsl:otherwise>
          </xsl:choose> comparison datasheet between 
          <xsl:choose>
            <xsl:when test="$LibMode != $GroupedMode">
              <span class="bold">
                <xsl:call-template name="CreateCornerStr">
                  <xsl:with-param name="Corner"  select="$RefNode"/>
                  <xsl:with-param name="Page"    select="$Page"/>
                  <xsl:with-param name="PDFLink" select="$PDFLink"/>
                </xsl:call-template>
              </span> and
              <span class="bold">
                <xsl:call-template name="CreateCornerStr">
                  <xsl:with-param name="Corner"  select="$TrgNode"/>
                  <xsl:with-param name="Page"    select="$Page"/>
                  <xsl:with-param name="PDFLink" select="$PDFLink"/>
                </xsl:call-template>
              </span>.
            </xsl:when>
            <xsl:otherwise>
              cells with same logical and timing characteristics.<br/>
              The relative sf value stands for the calculated strength factor normalized by the group reference cell.
            </xsl:otherwise>
          </xsl:choose>
      </xsl:if>
      
      <xsl:if test="($LibMode=$DevMode or $LibMode=$GroupedMode) and $Page!='QoRMeasures'">
        The units of the tables represent the calculation of the comparison values using: (target/reference) - 1.
      </xsl:if>
      <xsl:if test="$LibMode=$DevMode and $Page='QoRMeasures'">
        Cell QoR is a weighted average of all QoR measures.
      </xsl:if>
      
    </xsl:if>

  </xsl:template>
  
  <!-- Helper to create corner info in all pages -->
  <xd:doc>
    Builds the corner information that is shown in the notes section
    <xd:param name="Page" type="string">name of the page for which the notes are being built</xd:param>
    <xd:param name="PDFLink" type="string">link to be used in the PDF version of the Databook</xd:param>
    <xd:param name="SrcName" type="string">name of the root element in the page being processed. Automatically fetched by the script</xd:param>
  </xd:doc>
  <xsl:template name="Corner">
   
    <xsl:param name="Page"/> 
    <xsl:param name="PDFLink"/> 
    <xsl:param name="SrcName" select="name(/*)"/>
    
<!--<xsl:choose>
      <xsl:when test="$Corner/@Name=$NoCorner">
        <p class="error">Corner information not available.</p>
      </xsl:when>
      <xsl:otherwise>-->
        
        <xsl:for-each select="/*/StatDescr/Param">
          <p><b><xsl:value-of select="@Name"/>: </b><xsl:value-of select="@Descr"/></p>
        </xsl:for-each>

          <xsl:variable name="Name" select="$CornerNode/@Name"/>
          
          <xsl:if test="$CornerNode/@Voltage or $CornerNode/@Temperature">Conditions for characterization library 
            <span class="bold"><xsl:value-of select="$CornerNode/@LibName"/></span>
            <xsl:if test="substring($CornerNode/@Name,1,9)!=$NoCorner">, corner 
              <span class="bold"><xsl:value-of select="$Name"/></span>
            </xsl:if>: 
            <xsl:if test="$CornerNode/@Voltage">Vdd=
              <xsl:variable name="voltLabelLength" select="string-length($unit/volt)-2"/>
              <span class="bold">
                <xsl:call-template name="FormatUnit">
                  <xsl:with-param name="value" select="$CornerNode/@Voltage"/>
                  <xsl:with-param name="pattern" select="'#.00'"/>
                </xsl:call-template>
              </span><xsl:value-of select="substring($unit/volt, 2, $voltLabelLength)"/>
              <xsl:if test="$CornerNode/@Temperature">, </xsl:if>
            </xsl:if> 
            <xsl:if test="$CornerNode/@Temperature">Tj=
              <span class="bold">
                <xsl:call-template name="FormatUnit">
                  <xsl:with-param name="value" select="$CornerNode/@Temperature"/>
                  <xsl:with-param name="pattern" select="'#.0'"/>
                </xsl:call-template>
              </span> deg. C
            </xsl:if>.
          </xsl:if>

          <xsl:if test="$Page!=''">
            <xsl:if test="$CornerNode/../Corner[@Name!=$Name]">Additional corners:
              <xsl:for-each select="$CornerNode/../Corner[@Name!=$Name]">
                
                <xsl:if test="position()>1">, </xsl:if>
                
                <xsl:call-template name="CreateCornerStr">
                  <xsl:with-param name="Page"    select="$Page"/>
                  <xsl:with-param name="PDFLink" select="$PDFLink"/>
                  <xsl:with-param name="SrcName" select="$SrcName"/>
                </xsl:call-template>
                
              </xsl:for-each>.
            </xsl:if>
          </xsl:if>
          
        <br/>

  <!--</xsl:otherwise>
    </xsl:choose>-->
    
  </xsl:template>
  
  
  
  <!-- Helper to create the corner string -->
  <xd:doc>
    Builds a string identifying the corresponding to the current page on another corner
    <xd:param name="Corner" type="element">a XML element containing corner information</xd:param>
    <xd:param name="Page" type="string">name of the page for which the notes are being built</xd:param>
    <xd:param name="PDFLink" type="string">link to be used in the PDF version of the Databook</xd:param>
    <xd:param name="SrcName" type="string">name of the root element in the page being processed. Automatically fetched by the script</xd:param>
  </xd:doc>
  <xsl:template name="CreateCornerStr">

    <xsl:param name="Corner"  select="."/>
    <xsl:param name="Page"    select="''"/>
    <xsl:param name="PDFLink" select="''"/>
    <xsl:param name="SrcName" select="name(/*)"/>

    <a>
      <xsl:if test="$SrcName!='QoRTable'">
    
        <xsl:variable name="XmlLib" select="document(concat('../../', $Corner/@File))"/>
    
        <xsl:choose>
          <xsl:when test="($SrcName='Cell' and $XmlLib/Library/Cells/CellType/descendant::*[@Name=$Page]) or
                          ($SrcName!='Cell' and $XmlLib/TimingSummary/Entry[@Link=$Page])">
            <xsl:attribute name="href">
              <xsl:choose>
                <xsl:when test="$Config/@doctype='PDF'">
                  <xsl:value-of select="concat('@', $PDFLink,' [',$Corner/@Name,']')"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="concat($Page,'_',$Corner/@Name,'.html#Notes')"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
          </xsl:when>
          <xsl:when test="($Page='FirstOrderOutputTransition' or $Page='FirstOrderPropagationDelay') and ($Corner/@Name='Absolute_Deviation' or $Corner/@Name='Relative_Deviation')">
            <xsl:attribute name="title">This page is not available for this corner.</xsl:attribute>
          </xsl:when>
          <xsl:when test="$Page='Capacitance' and $Corner/@Name!='Absolute_Deviation' and $Corner/@Name!='Relative_Deviation'">
            <xsl:attribute name="title">This page is not available for this corner.</xsl:attribute>
          </xsl:when>
          <xsl:when test="$SrcName='Profilings'">
            <xsl:choose>
              <xsl:when test="$XmlLib/Library/Profilings/Plot/Plot[@File=$Page]">
                <xsl:attribute name="href">
                  <xsl:value-of select="concat($Page, '_', $Corner/@Name, $Extensions/Profiling)"/>
                </xsl:attribute>
              </xsl:when>
              <xsl:otherwise>
                <xsl:attribute name="title">This page is not available for this corner.</xsl:attribute>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="$SrcName='Cell'"> <!-- Is cell but has no matching entry (in first when test) -->
            <xsl:attribute name="title">This page is not available for this corner.</xsl:attribute>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="href">
              <xsl:value-of select="concat($Page, '_', $Corner/@Name, $Extensions/Summary)"/>
            </xsl:attribute>
          </xsl:otherwise>
        </xsl:choose>

      </xsl:if>
        
      <xsl:value-of select="concat($Corner/@LibName, ' [', $Corner/@Name, ']')"/>
    </a>
  </xsl:template>
  
  
  
  <!-- Helper to create the collapse behavior everywhere -->
  <xd:doc>
    Adds collapse behaviour to the current section of the page
    <xd:param name="name" type="string">name of the current section</xd:param>
    <xd:param name="tag" type="string">address used to link to this section. Default value is a copy of <i>name</i></xd:param>
    <xd:param name="parentTag" type="string">address used to link to the father of this section</xd:param>
    <xd:param name="short" type="boolean">true if the function should create a summary entry, false it if should be a collapse. Default value is <i>false</i></xd:param>
    <xd:param name="dir" type="string">path to the point where the <i>resource</i> folder is located. Default is the current directory</xd:param>
    <xd:param name="textStyle" type="string">defines the style to be applied to the name of the section. Default is <i>Caption</i> (or <i>Summary</i> if short is true)</xd:param>
    <xd:param name="hide" type="boolean">defines if the branch should start out hidden. Default value is <i>false</i></xd:param>
    <xd:param name="legend" type="string">text explaining the meaning of the section</xd:param>
  </xd:doc>
  <xsl:template name="CreateCollapse">

    <xsl:param name="name"/>
    <xsl:param name="tag" select="$name"/>
    <xsl:param name="parentTag"/>
    <xsl:param name="short">false</xsl:param>
    <xsl:param name="dir">.</xsl:param>
    <xsl:param name="textStyle">
      <xsl:choose>
        <xsl:when test="$short='true'">Summary</xsl:when>
        <xsl:otherwise>Caption</xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <xsl:param name="hide">false</xsl:param>
    <xsl:param name="extra"/>
    <xsl:param name="legend"/>

    <xsl:variable name="link">
      <xsl:choose>
        <xsl:when test="$short='true'">#<xsl:value-of select="$tag"/></xsl:when>
        <xsl:otherwise>javascript:;</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="textLink"><xsl:if test="$short='true'"><xsl:value-of select="$tag"/></xsl:if></xsl:variable>

    <xsl:choose>
      <xsl:when test="$DocType!='PDF'">
        <table>
          <xsl:attribute name="class">
            <xsl:choose>
              <xsl:when test="$short='true'">Summary</xsl:when>
              <xsl:otherwise>Caption</xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <colgroup><col/><col/></colgroup>
          <tr>
            <xsl:if test="$short='false'">
              <td>
              <xsl:attribute name="onClick">tBr('_<xsl:value-of select="$tag"/>');</xsl:attribute>
                <a class="Caption">
                  <xsl:attribute name="href"><xsl:value-of select="$link"/></xsl:attribute>
                  <span>
                    <xsl:attribute name="id">I_<xsl:value-of select="$tag"/></xsl:attribute>
                    <img border="0">
                      <xsl:attribute name="src"><xsl:value-of select="$dir"/>/resource/image/<xsl:choose><xsl:when test="$hide='true'">close</xsl:when><xsl:otherwise>open</xsl:otherwise></xsl:choose>_square.gif</xsl:attribute>
                    </img>
                  </span>&#160;&#160;
                </a>
              </td>
            </xsl:if>
            
            <td>
              <xsl:element name="a">
                <xsl:choose>
                  <xsl:when test="$short='true' and $parentTag!=''">
                    <xsl:attribute name="onClick">oBrs('_<xsl:value-of select="$textLink"/>', '_<xsl:value-of select="$parentTag"/>');</xsl:attribute>
                  </xsl:when>
                  <xsl:when test="$short='true'">
                    <xsl:attribute name="onClick">oBr('_<xsl:value-of select="$textLink"/>');</xsl:attribute>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:attribute name="onClick">tBr('_<xsl:value-of select="$tag"/>');</xsl:attribute>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:attribute name="class"><xsl:value-of select="$textStyle"/></xsl:attribute>
                <xsl:attribute name="href"><xsl:value-of select="$link"/></xsl:attribute>
                <xsl:if test="$short='true'">- </xsl:if>
                <xsl:value-of select="$name"/>
              </xsl:element>
              <xsl:if test="$short='false' and $tag!='Summary' and $isCellPage='true'">
                <xsl:text>&#160;&#160;&#160;</xsl:text>
                <xsl:element name="a">
                  <xsl:attribute name="onClick">oBr('_Summary')</xsl:attribute>
                  <xsl:attribute name="href">#<xsl:value-of select="$textLink"/></xsl:attribute>
                  <img border="0"><xsl:attribute name="src"><xsl:value-of select="$dir"/>/resource/image/to_summary.png</xsl:attribute></img>
                </xsl:element>
              </xsl:if>
            </td>
            <xsl:if test="$short='false' and $extra != ''">
              <td>
                <xsl:text>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;</xsl:text>
                <xsl:element name="span">
                  <xsl:attribute name="class">extra</xsl:attribute>
                  <xsl:copy-of select="$extra"/>
                </xsl:element>
              </td>
            </xsl:if>
            <xsl:if test="$legend != ''">
              <td>
                <xsl:text>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;</xsl:text>
                <xsl:element name="span">
                  <xsl:attribute name="class">legend<xsl:if test="$short='true'">_summary</xsl:if></xsl:attribute>
                  [<xsl:copy-of select="$legend"/>]
                </xsl:element>
              </td>
            </xsl:if>
          </tr>
        </table>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="p">
          <xsl:attribute name="class"><xsl:value-of select="$textStyle"/></xsl:attribute>
          <xsl:value-of select="$name"/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:template>
  
  
  
  <xd:doc>
    Returns the mapped value associated to the given key
    <xd:param name="key" type="string">name of the key whose value is being queried</xd:param>
    <xd:param name="map" type="element">a XML element containing the pairs (key, value). Default value uses the local variable <i>MapNode</i></xd:param>
  </xd:doc>
  <xsl:template name="Map">
    
    <xsl:param name="key"/>
    <xsl:param name="map" select="$MapNode"/>
    
    <xsl:choose>
      <xsl:when test="$map/entry[@key=normalize-space($key)]">
        <xsl:value-of select="$map/entry[@key=normalize-space($key)]/@value"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat('UNKNOWN_KEY=',$key)"/>
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:template>
  
  
  
  <!-- Helper to print values with interpolation -->
  <xd:doc>
    Outputs the given text in italic if it comes from interpolation 
    <xd:param name="text" type="string">text to be copied to the output</xd:param>
    <xd:param name="interpolation" type="string">if it comes from interpolation, applies italic style to <i>text</i></xd:param>
  </xd:doc>
  <xsl:template name="interpolation">
    
    <xsl:param name="text"/>
    <xsl:param name="interpolation"/>
    
    <xsl:choose>
      <xsl:when test="$interpolation='yes'">
        <i><xsl:value-of select="$text"/></i>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$text"/>
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:template>
  
  
  
  <!-- Helper to print values with tolerance exceeded -->
  <xd:doc>
    Outputs the given text indicating if it exceeds the expected tolerance
    <xd:param name="text" type="string">text to be copied to the output</xd:param>
    <xd:param name="exceeded" type="string">if set to "up" or "down", applies the appropriate style to <i>text</i></xd:param>
    <xd:param name="interpolation" type="string">if it comes from interpolation, applies italic style to <i>text</i></xd:param>
  </xd:doc>
  <xsl:template name="exceeded">
    
    <xsl:param name="text"/>
    <xsl:param name="exceeded"/>
    <xsl:param name="interpolation"/>
    
    <xsl:choose>
      <xsl:when test="$exceeded='up'">
        <span class="erU">
        <xsl:call-template name="interpolation">
          <xsl:with-param name="text" select="$text"/>
          <xsl:with-param name="interpolation" select="$interpolation"/>
        </xsl:call-template>
        </span>
      </xsl:when>
      <xsl:when test="$exceeded='down'">
        <span class="erD">
        <xsl:call-template name="interpolation">
          <xsl:with-param name="text" select="$text"/>
          <xsl:with-param name="interpolation" select="$interpolation"/>
        </xsl:call-template>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="interpolation">
          <xsl:with-param name="text" select="$text"/>
          <xsl:with-param name="interpolation" select="$interpolation"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:template>
  
  
  
  <!-- Helper to change background color when the value is negative -->
  <xd:doc>
    Changes the background color if the value is negative 
    <xd:param name="text" type="string">text to be copied to the output</xd:param>
  </xd:doc>
  <xsl:template name="negative">
    
    <xsl:param name="text"/>
    
    <xsl:choose>
      <xsl:when test="contains($text, '-')">
        <xsl:attribute name="class">neg</xsl:attribute>
      </xsl:when>
    </xsl:choose>
    
  </xsl:template> 
  
  <!-- reusable replace-string function -->
  <xd:doc>
    Replaces ocurrences of string 'from' to 'to' in 'text'
    <xd:param name="text" type="string">target text</xd:param>
    <xd:param name="from" type="string">string to search for</xd:param>
    <xd:param name="to" type="string">string to use as replacement</xd:param>
  </xd:doc>
  <xsl:template name="replaceString">
    <xsl:param name="text"/>
    <xsl:param name="from"/>
    <xsl:param name="to"/>
    <xsl:choose>
      <xsl:when test="contains($text, $from)">
        <xsl:variable name="before" select="substring-before($text, $from)"/>
        <xsl:variable name="after" select="substring-after($text, $from)"/>
        <xsl:variable name="prefix" select="concat($before, $to)"/>
        <xsl:value-of select="$before"/>
        <xsl:value-of select="$to"/>
        <xsl:call-template name="replaceString">
          <xsl:with-param name="text" select="$after"/>
          <xsl:with-param name="from" select="$from"/>
          <xsl:with-param name="to" select="$to"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$text"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xd:doc>
    Uses JavaScript to create a link that opens the CTP page in a new window
    <xd:param name="XmlLib" type="node">Root node containing CTP information</xd:param>
    <xd:param name="path" type="string">Path to databook folder. Default: current folder</xd:param>
    <xd:param name="type" type="string">Type of page, 'propagation' or 'slope'</xd:param>
    <xd:param name="unateness" type="string">Transition type</xd:param>
    <xd:param name="risefall" type="string">'rise' or 'fall' graph</xd:param>
  </xd:doc>

  <xsl:template name="CreateCTPLink">
    <xsl:param name="XmlLib"/>
    <xsl:param name="path">.</xsl:param>
    <xsl:param name="type"></xsl:param>
    <xsl:param name="unateness"></xsl:param>
    <xsl:param name="risefall"></xsl:param>


    <xsl:variable name="default_prop">50</xsl:variable>
    <xsl:variable name="default_slew_upper">80</xsl:variable>
    <xsl:variable name="default_slew_lower">20</xsl:variable>

    <xsl:variable name="input_threshold_rise">
      <xsl:choose>
        <xsl:when test="$XmlLib/input_threshold_pct_rise">
          <xsl:value-of select="number($XmlLib/input_threshold_pct_rise)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$default_prop"/>
          <xsl:text>*</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="input_threshold_fall">
      <xsl:choose>
        <xsl:when test="$XmlLib/input_threshold_pct_fall">
          <xsl:value-of select="number($XmlLib/input_threshold_pct_fall)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$default_prop"/>
          <xsl:text>*</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="output_threshold_rise">
      <xsl:choose>
        <xsl:when test="$XmlLib/output_threshold_pct_rise">
          <xsl:value-of select="number($XmlLib/output_threshold_pct_rise)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$default_prop"/>
          <xsl:text>*</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="output_threshold_fall">
      <xsl:choose>
        <xsl:when test="$XmlLib/output_threshold_pct_fall">
          <xsl:value-of select="number($XmlLib/output_threshold_pct_fall)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$default_prop"/>
          <xsl:text>*</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="slew_upper_fall">
      <xsl:choose>
        <xsl:when test="$XmlLib/slew_upper_threshold_pct_fall">
          <xsl:value-of select="number($XmlLib/slew_upper_threshold_pct_fall)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$default_slew_upper"/>
          <xsl:text>*</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="slew_lower_fall">
      <xsl:choose>
        <xsl:when test="$XmlLib/slew_lower_threshold_pct_fall">
          <xsl:value-of select="number($XmlLib/slew_lower_threshold_pct_fall)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$default_slew_lower"/>
          <xsl:text>*</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="slew_lower_rise">
      <xsl:choose>
        <xsl:when test="$XmlLib/slew_lower_threshold_pct_rise">
          <xsl:value-of select="number($XmlLib/slew_lower_threshold_pct_rise)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$default_slew_lower"/>
          <xsl:text>*</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="slew_upper_rise">
      <xsl:choose>
        <xsl:when test="$XmlLib/slew_upper_threshold_pct_rise">
          <xsl:value-of select="number($XmlLib/slew_upper_threshold_pct_rise)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$default_slew_upper"/>
          <xsl:text>*</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="pagetype">
      <xsl:choose>
        <xsl:when test="$type='propagation'">
          <xsl:choose>
            <xsl:when test="$unateness='positive'">
              <xsl:choose>
                <xsl:when test="$risefall='rise'">propposrise</xsl:when>
                <xsl:when test="$risefall='fall'">propposfall</xsl:when>
              </xsl:choose>
            </xsl:when>           
            <xsl:when test="$unateness='negative'">
              <xsl:choose>
                <xsl:when test="$risefall='rise'">propnegrise</xsl:when>
                <xsl:when test="$risefall='fall'">propnegfall</xsl:when>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <xsl:choose>
                <xsl:when test="$risefall='rise'">propbinrise</xsl:when>
                <xsl:when test="$risefall='fall'">propbinfall</xsl:when>
              </xsl:choose>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="$type='slope'">
          <xsl:choose>
            <xsl:when test="$risefall='rise'">sloperise</xsl:when>
            <xsl:when test="$risefall='fall'">slopefall</xsl:when>
          </xsl:choose>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="value1">
      <xsl:choose>
        <xsl:when test="normalize-space($pagetype) = 'propposrise'">
          <xsl:value-of select="$input_threshold_rise"/>
        </xsl:when>
        <xsl:when test="normalize-space($pagetype) = 'propposfall'">
          <xsl:value-of select="$input_threshold_fall"/>
        </xsl:when>
        <xsl:when test="normalize-space($pagetype) = 'propnegrise'">
          <xsl:value-of select="$input_threshold_fall"/>
        </xsl:when>
        <xsl:when test="normalize-space($pagetype) = 'propnegfall'">
          <xsl:value-of select="$input_threshold_rise"/>
        </xsl:when>
        <xsl:when test="normalize-space($pagetype) = 'propbinrise'">
          <xsl:value-of select="$input_threshold_rise"/>
        </xsl:when>
        <xsl:when test="normalize-space($pagetype) = 'propbinfall'">
          <xsl:value-of select="$input_threshold_rise"/>
        </xsl:when>
        <xsl:when test="normalize-space($pagetype) = 'sloperise'">
          <xsl:value-of select="$slew_upper_rise"/>
        </xsl:when>
        <xsl:when test="normalize-space($pagetype) = 'slopefall'">
          <xsl:value-of select="$slew_upper_fall"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="value2">
      <xsl:choose>
        <xsl:when test="normalize-space($pagetype) = 'propposrise'">
          <xsl:value-of select="$output_threshold_rise"/>
        </xsl:when>
        <xsl:when test="normalize-space($pagetype) = 'propposfall'">
          <xsl:value-of select="$output_threshold_fall"/>
        </xsl:when>
        <xsl:when test="normalize-space($pagetype) = 'propnegrise'">
          <xsl:value-of select="$output_threshold_rise"/>
        </xsl:when>
        <xsl:when test="normalize-space($pagetype) = 'propnegfall'">
          <xsl:value-of select="$output_threshold_fall"/>
        </xsl:when>
        <xsl:when test="normalize-space($pagetype) = 'propbinrise'">
          <xsl:value-of select="$output_threshold_rise"/>
        </xsl:when>
        <xsl:when test="normalize-space($pagetype) = 'propbinfall'">
          <xsl:value-of select="$output_threshold_fall"/>
        </xsl:when>
        <xsl:when test="normalize-space($pagetype) = 'sloperise'">
          <xsl:value-of select="$slew_lower_rise"/>
        </xsl:when>
        <xsl:when test="normalize-space($pagetype) = 'slopefall'">
          <xsl:value-of select="$slew_lower_fall"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="value3">
      <xsl:choose>
        <xsl:when test="normalize-space($pagetype) = 'propbinrise'">
          <xsl:value-of select="$input_threshold_fall"/>
        </xsl:when>
        <xsl:when test="normalize-space($pagetype) = 'propbinfall'">
          <xsl:value-of select="$input_threshold_fall"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="graphnumber">
      <xsl:choose>
        <xsl:when test="starts-with($pagetype,'proppos')">2</xsl:when>
        <xsl:when test="starts-with($pagetype,'propneg')">2</xsl:when>
        <xsl:when test="starts-with($pagetype,'propbin')">3</xsl:when>
        <xsl:when test="starts-with($pagetype,'slope')">1</xsl:when>
      </xsl:choose>
    </xsl:variable>

    <a>   
      <!-- Please do not indentate next tag otherwise it adds unnecessary characters to the HTML file -->
      <xsl:attribute name="href">javascript:openctpPage('<xsl:value-of select="$path"/>','<xsl:value-of select="$graphnumber"/>','<xsl:value-of select="$unateness"/>','<xsl:value-of select="$risefall"/>','<xsl:value-of select="$value1"/>','<xsl:value-of select="$value2"/>','<xsl:value-of select="$value3"/>');</xsl:attribute>
      <xsl:value-of select="$risefall"/>
    </a>  

  </xsl:template>
  
  <xd:doc>
    Uses JavaScript to create a link that opens the constraint validation help in new window
    <xd:param name="path" type="string">Path to databook folder. Default: current folder</xd:param>
    <xd:param name="type" type="string">Type of page, 'N', 'S'  or 'W'</xd:param>
    <xd:param name="name" type="string">Link name</xd:param>
  </xd:doc>

  <xsl:template name="CreateCValidLink">
    <xsl:param name="path">.</xsl:param>
    <xsl:param name="type"></xsl:param>
    <xsl:param name="name"></xsl:param>

    <a>   
      <!-- Please do not indentate next tag otherwise it adds unnecessary characters to the HTML file -->
      <xsl:attribute name="href">javascript:openCValidPage('<xsl:value-of select="$path"/>','<xsl:value-of select="$type"/>');</xsl:attribute>
      <xsl:value-of select="$name"/>
    </a>  

  </xsl:template>
  <xd:doc>
    Builds the corner information that is displayed in the title notes
    <xd:param name="Page" type="string">name of the page for which the notes are being built</xd:param>
    <xd:param name="PDFLink" type="string">link to be used in the PDF version of the Databook</xd:param>
  </xd:doc>
  <xsl:template name="CreateTitleCornerNote">
    
    <xsl:param name="Page"/>
    <xsl:param name="PDFLink" select="''"/>
    
    <xsl:if test="substring(@CornerName,1,9)!=$NoCorner">

      <xsl:choose>
        <xsl:when test="$CornerNode/@Ref">

          Datasheet with
          <xsl:choose>
            <xsl:when test="$LibMode=$DevModeAbs">an absolute</xsl:when>
            <xsl:when test="$LibMode=$DevModeBest">a best case</xsl:when>
            <xsl:when test="$LibMode=$DevModeWorst">a worst case</xsl:when>
            <xsl:when test="$LibMode=$DevMode and $Page='QoRMeasures'">QoR measures retrieved from a relative</xsl:when>
            <xsl:otherwise>a relative</xsl:otherwise>
          </xsl:choose>
          comparison
          <xsl:choose>
            <xsl:when test="$CornerNode/@Focus">
              <span class="bold">(<xsl:value-of select="$CornerNode/@Focus"/> focus)</span>
            </xsl:when>
          </xsl:choose>
          between 
          <xsl:choose>
            <xsl:when test="$LibMode != $GroupedMode">
              <xsl:value-of select="$RefNode"/>
              <span class="bold">
                <xsl:call-template name="CreateCornerStr">
                  <xsl:with-param name="Corner"  select="$RefNode"/>
                  <xsl:with-param name="Page"    select="$Page"/>
                  <xsl:with-param name="PDFLink" select="$PDFLink"/>
                </xsl:call-template>
              </span> and
              <span class="bold">
                <xsl:call-template name="CreateCornerStr">
                  <xsl:with-param name="Corner"  select="$TrgNode"/>
                  <xsl:with-param name="Page"    select="$Page"/>
                  <xsl:with-param name="PDFLink" select="$PDFLink"/>
                </xsl:call-template>
              </span>.
            </xsl:when>
            <xsl:otherwise>
              cells with same logical and timing characteristics.
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          Datasheet for characterization corner: <span class="bold"><xsl:value-of select="@CornerName"/></span>
          <xsl:if test="$XmlLibrary">
            , library <span class="bold"><xsl:value-of select="$XmlLibrary/Library/MainAttributes/Name"/></span>
          </xsl:if>.
        </xsl:otherwise>
      </xsl:choose>
      
      
    </xsl:if>
    
  </xsl:template>

  
  
  <xd:doc>
    Builds the profiling title, shown in the profiling pages and in the table of contents
  </xd:doc>
  <xsl:template name="buildProfilingTitle">
    <xsl:call-template name="Map">
      <xsl:with-param name="map" select="$MapNode/profiling_plots"/>
      <xsl:with-param name="key" select="@Name"/>
    </xsl:call-template>
    <xsl:choose>
      <xsl:when test="@Prefix">
        (<xsl:choose>
          <xsl:when test="@Prefix='Avg_Dev' or @Prefix='Worst_Dev'">Arc Based</xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="Map">
              <xsl:with-param name="map" select="$MapNode/profiling_plots"/>
              <xsl:with-param name="key" select="@Prefix"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>)
      </xsl:when>
      <xsl:when test="((count(../@Name)=0 and name(..)!='Profilings') or ../@Name!='cell') and @Name!='area' and @Name!='cell_leakage_power'"> (Cell Based)</xsl:when>
    </xsl:choose>
  </xsl:template>


  <!-- Helper for generating summary table caption -->
  <xd:doc>Creates the caption (with collapse) for a summary table</xd:doc>
  <xsl:template name="CreateTableCaption">
    
    <xsl:variable name="title">
      <xsl:choose>
        <xsl:when test="../@Name=$FOOS">
          Output Transition
         </xsl:when>
        <xsl:when test="../@Name=$FOPD">
          Propagation Delay 
        </xsl:when>
        <xsl:when test="../@Name=$OS">
          Output Transition
        </xsl:when>
        <xsl:when test="../@Name=$MP">
          Minimum Pulse Width
        </xsl:when>
        <xsl:when test="../@Name=$OSRatio">
          Output Transition Ratio
        </xsl:when>
        <xsl:when test="../@Name=$PD">
          Propagation Delay
        </xsl:when>
        <xsl:when test="../@Name=$FCD">
          Full-Cycle Delay
        </xsl:when>
        <xsl:when test="../@Name=$PDRatio">
          Propagation Delay Ratio 
        </xsl:when>
        <xsl:when test="../@Name=$FO4D">
          Fanout 4 Delay
        </xsl:when>
        <xsl:when test="../@Name=$PWR">
          Power 
        </xsl:when>
        <xsl:when test="../@Name=$RP">
          Rise Power
        </xsl:when>
        <xsl:when test="../@Name=$FP">
          Fall Power
        </xsl:when>
        <xsl:when test="../@Name=$FCP">
          Full-Cycle Power
        </xsl:when>
        <xsl:when test="../@Name=$TFCP">
          Total Full-Cycle Power
        </xsl:when>
        <xsl:when test="../@Name=$TP">
          Total Power
        </xsl:when>
        <xsl:when test="../@Name=$TPF">
          Total Power Fall
        </xsl:when>
        <xsl:when test="../@Name=$TPR">
          Total Power Rise
        </xsl:when>
        <xsl:when test="../@Name=$MS">
          Setup/Hold Metastability Window
        </xsl:when>
        <xsl:when test="../@Name=$RRMS">
          Recovery + Removal 
        </xsl:when>
        <xsl:when test="../@Name=$DQ">
          Constrained Data To Output Delay
        </xsl:when>
        <xsl:when test="../@Name=$ST">
          Setup Time
        </xsl:when>
        <xsl:when test="../@Name=$HT">
          Hold Time 
        </xsl:when>
        <xsl:when test="../@Name=$RC">
          Recovery Time 
        </xsl:when>
        <xsl:when test="../@Name=$RM">
          Removal Time 
        </xsl:when>
        <xsl:when test="../@Name=$CAP">
          Gate Capacitance 
        </xsl:when>
        <xsl:when test="../@Name=$SP">
          Leakage Power
        </xsl:when>
        <xsl:when test="../@Name=$MXC">
          Maximum Capacitance
        </xsl:when>
        <xsl:when test="/*/@Name=$QOR">
          QoR Measures
        </xsl:when>
        <xsl:when test="/*/@Name=$PDV">
          Propagation Delay Voltage Threshold
        </xsl:when>
        <xsl:otherwise>
          <xsl:if test="/*/@Name=$CTV">
            <xsl:value-of select="@name"/>
          </xsl:if>
        </xsl:otherwise>

      </xsl:choose>

    </xsl:variable>

    <xsl:variable name="ExtraTitle">
      <xsl:text> </xsl:text>
      <xsl:call-template name="TableCaption">
        <xsl:with-param name="trans">
          <xsl:if test="../@Name=$RM or ../@Name=$RC or ../@Name=$HT or ../@Name=$ST or ../@Name=$MS or ../@Name=$RRMS or ../@Name=$DQ or ../@Name=$MP">yes</xsl:if>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:text> </xsl:text>
      <xsl:choose>
        <xsl:when test="../@Name=$FOOS or ../@Name=$OS or ../@Name=$OSRatio">          
          <xsl:call-template name="WriteThresholds">
            <xsl:with-param name="type" select="'slope'"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="../@Name=$FOPD or ../@Name=$PD or ../@Name=$PDV or ../@Name=$PDRatio or ../@Name=$FO4D">          
          <xsl:call-template name="WriteThresholds">
            <xsl:with-param name="type" select="'propagation'"/>
          </xsl:call-template>
        </xsl:when>
      </xsl:choose>
      <xsl:text> </xsl:text>
      <xsl:if test="../@Name=$FOOS or ../@Name=$FOPD">(OL<xsl:value-of select="$unit/capacitance"/>)</xsl:if>
    </xsl:variable>
   

    <xsl:call-template name="CreateCollapse">
      <xsl:with-param name="name" select="$title"/>
      <xsl:with-param name="tag"  select="concat('Table_', @Id)"/>
      <xsl:with-param name="dir">.</xsl:with-param>
      <xsl:with-param name="extra" select="$ExtraTitle"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Writes the propagation delay thresholds -->  
  <xd:doc>Builds the threshold information. Calls the <i>CreateCTPLink</i> template</xd:doc>
  <xsl:template name="WriteThresholds">
    <xsl:param name="type"/>
    <xsl:choose>
      <xsl:when test="$LibMode!='normal'">
        <xsl:call-template name="CreateCTPLink">
          <xsl:with-param name="XmlLib" select="$RefXmlLib"/>
          <xsl:with-param name="type" select="$type"/>
          <xsl:with-param name="unateness">binate</xsl:with-param>
          <xsl:with-param name="risefall" select="@Transition"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="CreateCTPLink">
          <xsl:with-param name="XmlLib" select="$XmlLibrary/Library"/>
          <xsl:with-param name="type" select="$type"/>
          <xsl:with-param name="unateness">binate</xsl:with-param>
          <xsl:with-param name="risefall" select="@Transition"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
 
  <!-- Generate table caption text properly -->
  <xd:doc>Generates the string to be used as caption for a table</xd:doc>
  <xsl:template name="TableCaption">
    <xsl:param name="trans" select="'no'"/>
    <xsl:if test="(@Strength!='Unknown' and @Strength!='') or (@Transition!='Unknown' and @Transition!='')"> @ </xsl:if>
    <xsl:if test="@Strength!='Unknown' and @Strength!='' and $LibMode != $GroupedMode">strength: <xsl:value-of select="@Strength"/></xsl:if>
    <xsl:if test="@Strength!='Unknown' and @Strength!='' and $LibMode = $GroupedMode">reference cell strength: <xsl:value-of select="@Strength"/></xsl:if>
    <xsl:if test="@Strength!='Unknown' and @Strength!='' and @Transition!='Unknown' and @Transition!=''"> and </xsl:if>
    <xsl:if test="@Transition!='Unknown' and @Transition!=''">transition: </xsl:if>
    <xsl:if test="@Strength!='Unknown' or @Transition!='Unknown'">
      <xsl:if test="$trans = 'yes'">
        <xsl:value-of select="@Transition"/>
      </xsl:if>
    </xsl:if>
  </xsl:template>  


  <!-- Generate table caption text properly -->
  <xd:doc>Generates the ref and trg links for cell pages</xd:doc>
  <xsl:template name="CreateRefTrg">
    <xsl:param name="address1"/>
    <xsl:param name="address2"/>
    <a>
      <xsl:attribute name="href"><xsl:value-of select="concat(/Cell/@Name, '_', $RefNode/@Name, $Extensions/Cell, $address1)"/></xsl:attribute>ref
    </a>
    <xsl:text>&#160;&#160;|&#160;&#160;</xsl:text>
    <a>
      <xsl:attribute name="href"><xsl:value-of select="concat(/Cell/@Name, '_', $TrgNode/@Name, $Extensions/Cell, $address2)"/></xsl:attribute>trg
    </a>
  </xsl:template>
  
</xsl:stylesheet>
