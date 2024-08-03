////////////////////////////////////////////////////////////////////////////////
///                                                                            /
///                   Copyright (C) 1984-2023 Silvaco, Inc.                    /
///                            All rights reserved.                            /
///                                                                            /
/// The Silvaco name and the Silvaco logo are trademarks of Silvaco, Inc.      /
/// and/or its affiliates ("Silvaco"). All trademarks, logos, software marks,  /
/// and trade names (collectively, the "Marks") in this program are            /
/// proprietary to Silvaco or other respective owners that have granted        /
/// Silvaco the right and license to use such Marks. You are not permitted to  /
/// use the Marks without the prior written consent of Silvaco or such third   /
/// party that may own the Marks.                                              /
///                                                                            /
/// This file has been provided pursuant to a license agreement containing     /
/// restrictions on its use. This file contains valuable trade secrets and     /
/// proprietary information of Silvaco and is protected by U.S. and            /
/// international laws.                                                        /
///                                                                            /
/// The copyright notice(s) in this file do not indicate actual or intended    /
/// publication of this file.                                                  /
///                                                                            /
////////////////////////////////////////////////////////////////////////////////

var svc_tt = null;
var svc_image = null;

function NgTooltip() {
  //-----------------
  // Class attributes
  //-----------------
  this.bgColor = "#FFFFCC";
  this.text = '';
  this.id = '';
  this.obj = null;
  this.active = false;
  this.okToFade = true;

  //--------
  // Methods
  //--------
  this.create = function() {
    var tdObj = document.getElementById(this.id);
    if (tdObj) {
      this.obj = document.createElement('div');
      this.obj.setAttribute('id', 'ToolTip');
      this.obj.setAttribute('style', 'position:absolute; visibility:hidden');
      tdObj.appendChild(this.obj);
    }

    var t = '<a href=' + this.text + ' onmouseover=\"doNotFade()\" onmouseout=\"doFade()\">See table from where this value was extracted</href>';

    var extraDiv = document.createElement('div');
    extraDiv.innerHTML += t;
    this.obj.appendChild(extraDiv);
    if (this.bgColor) 
      this.obj.style.backgroundColor = this.bgColor;

    this.show();
  }

  this.show = function() {
    this.obj.style.zIndex = 69;
    this.active = true;
    this.obj.style.visibility = 'visible';
    this.obj.style.display = 'block';
  }

  this.hide = function() {
    var _self = this;
    setTimeout(function() {_self.fadeOut();}, 100);
  }

  this.fadeOut = function() {
    if (this.okToFade) {
      this.obj.style.zIndex = -1;
      this.active = false;
      this.obj.style.visibility = 'hidden';
      this.obj.style.display = 'none';
    }
  }
}

function NgImTooltip() {
  //-----------------
  // Class attributes
  //-----------------
  this.id = '';
  this.obj = null;

  //--------
  // Methods
  //--------
  this.create = function() {
    var images = document.getElementById(this.id).getElementsByTagName('div')[0].getElementsByTagName('img');
    this.obj = images[0];
    this.show();
  }

  this.show = function() {
    this.obj.style.display = "inline";
  }

  this.hide = function() {
    var _self = this;
    setTimeout(function() {_self.fadeOut();}, 2500);
  }

  this.fadeOut = function() {
    this.obj.style.display = 'none';
  }
}

function tt(id, text) {
  if (id && !text) {
    svc_image = new NgImTooltip();
    svc_image.id = id;
    svc_image.create();
  } else if (text && id) {
    svc_tt = new NgTooltip();  
    svc_tt.text = text;
    svc_tt.id = id;
    svc_tt.create();
  }
  else if (svc_tt)
    svc_tt.hide();
  else if (svc_image)
    svc_image.hide();
}

function doNotFade() {
  svc_tt.okToFade = false;
}

function doFade() {
  svc_tt.okToFade = true;
  svc_tt.fadeOut();
}

function createToolTips() {
  var elems=document.getElementsByTagName('div'); 
  for (var j = 0; j < elems.length; j++) {
    var ttDiv = elems[j].getAttribute('cTt');
    if (ttDiv != null) {
      var parent = elems[j].parentNode;
      var id = parent.getAttribute('id');
      elems[j].onmouseover=new Function('tt(\''+id+'\', \''+ttDiv+'\')');
      elems[j].onmouseout=new Function('tt()');
    }
  }
}

function createHighlight() {
  var elems=document.getElementsByTagName('td'); 
  for (var j = 0; j < elems.length; j++) {
    var ttDiv = elems[j].className;
    if (ttDiv != null) {
      if ((ttDiv == 'num') || (ttDiv == 'neg')) {
        elems[j].onmouseover = new Function('highlight(this)');
        elems[j].onmouseout  = new Function('highlight(this)');
        elems[j].onclick     = new Function('highlight(this)');
      }
    }
  }
}
