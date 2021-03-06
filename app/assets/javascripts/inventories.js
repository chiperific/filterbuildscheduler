function filterView(type, button) {
  // type == "count" or "tech"
  // button ids: [clear, uncounted, partial, counted]
  var btnId = $(button).attr("id");
  var target = "." + btnId;

  if (type == "count") {
    var goal = "true"
    var parentId = ""
    if (btnId == "uncounted") {
      target = ".counted";
      goal = "false";
    };
    $(target).each(function() {
      parentId = "#" + $(this).parents(".count-parent").attr("id");
      if ( $(this).attr("title") != goal ) {
        $(parentId).hide();
      } else {
        $(parentId).show();
      };
    });

  } else { // type = "tech"
    var goalStr = target.substring(6, target.length);
    $(".techs").each(function() {
      parentId = "#" + $(this).parents(".count-parent").attr("id");
      var techStr = $(this).attr("title");
      var techAry = techStr.split(",");
      if ( techAry.includes(goalStr) ) {
        $(parentId).show();
      } else {
        $(parentId).hide();
      };
    });
  };
};

function stringMaker(float, fixed) {
  num = float.toFixed(fixed);
  return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
};

function orderTotal() {
  var range = [ $("#order_item_div"), $("#order_supplier_div") ];
  var target = [ $("#item_ttl"), $("#supplier_ttl") ];
  var ttl = [];
  var ttlStr = [];
  var amtStr, amt;

  for( i = 0; i < range.length; i++ ) {
    var booleans = range[i].find(".order_checkbox").get();
    ttl[i] = 0;

    for( j = 0; j < booleans.length; j++ ) {
      if (booleans[j].checked === true ) {
        amtStr = $( "#" + booleans[j].id ).parent(".order-check").siblings(".order-total").find(".order-total-amt").html();
        amt = parseFloat( amtStr.replace(",","") );
        ttl[i] += amt;
      };
    };

    ttlStr[i] = stringMaker(ttl[i], 2);
    target[i].html(ttlStr[i]);
  };
};

function toggleCheck(action,scope) {
  if(scope === "all") {
    var booleans = $(".order_checkbox").get();
  } else {
    // scope === id
    var tableId = "#order_supplier_tbl_" + scope
    var booleans = $(tableId).find("input.order_checkbox").get();
  };

  if(action === "check") {
    for( i = 0; i < booleans.length; i++ ) {
        booleans[i].checked = true;
        // twinSnyc(booleans[i]);
      };
  } else if(action === "uncheck") {
    for( i = 0; i < booleans.length; i++ ) {
        booleans[i].checked = false;
        // twinSnyc(booleans[i]);
      };
  };
  orderTotal();
};

function twinSnyc(checkboxA) {
  var idStr = $(checkboxA).attr("id");
  var inputA = $(checkboxA).parent('.order-check').siblings('.min-order').find('.min-order-field')
  var quantity = parseFloat( $(inputA).val().replace(",","") );
  var state = $(checkboxA).prop("checked")
  var split = idStr.split("_");
  // split: ("checkbox",["item", "supplier"],"id")
  if(split[1] === "item") {
    var locator = "supplier";
  } else {
    var locator = "item";
  };

  var checkboxB = "#checkbox_" + locator + "_" + split[2];
  $(checkboxB).prop("checked", state);

  var inputB = "#" + locator + "_min_order_" + split[2];
  $(inputB).val(quantity);
  reformat(inputB);
};

function lineTotal(source) {
  var quantity = parseFloat( $(source).val().replace(",","") );
  var itemCostSpan = $(source).parent(".min-order").siblings(".item-cost").find(".item-cost-value");
  var itemCost = parseFloat( $(itemCostSpan).html().replace(",","") );

  var newTotalStr = stringMaker( (quantity * itemCost), 2 );
  var totalCostSpan = $(source).parent(".min-order").siblings(".order-total").find(".order-total-amt");
  $(totalCostSpan).html(newTotalStr);
};

function lineCheck(source) {
  var checkbox = $(source).parent(".min-order").siblings(".order-check").find(".order_checkbox");
  if( $(checkbox).prop("checked") === false ) {
    $(checkbox).prop("checked", true);
  };
  twinSnyc(checkbox);
};

function reformat(source) {
  var unformatted = $(source).val();
  var formatted = unformatted.replace(/\B(?=(\d{3})+(?!\d))/g, ",");
  $(source).val(formatted);
};

function countFetcher() {
  var invId = window.location.pathname.match(/\d+/)[0];
  var url = '/inventories/' + invId + '/counts/polled_index.js';
  $.get(url, function(){});
};

var poller;

(function() {
  // Inventory#edit finalize buttons
  $(document).on("click", "#show_finalize_form", function() {
    $('#finalize_form').fadeIn();
    $('#counts_div').hide();
    $('#filter_div').hide();
    event.preventDefault();
  });
  $(document).on("click", "#hide_finalize_form", function() {
    $('#finalize_form').hide();
    $('#counts_div').fadeIn();
    $('#filter_div').fadeIn();
    event.preventDefault();
  });
  // Inventory#edit filter buttons
  $(document).on("click", ".count-btn", function() {
    filterView("count", this);
    event.preventDefault();
  });
  $(document).on("click", ".tech-btn", function() {
    filterView("tech", this);
    event.preventDefault();
  });
  $(document).on("click", "#clear", function() {
    $(".count-parent").show();
    event.preventDefault();
  });

  // Inventory#edit search field
  $(document).on("keyup", "#search", function() {
    var term = $("#search").val().toUpperCase();
    var collection = $(".count-parent").get();
    var title;
    var uid;

    if (term === "") {
      $('.count-parent').show();
    } else {
      for ( i = 0; i < collection.length; i++ ) {
      title = $(collection[i]).find(".count-title");
      uid = $(collection[i]).find(".count-uid");
      tech = $(collection[i]).find(".count-tech");
      if (
        $(title).html().toUpperCase().indexOf(term) === -1
        && $(uid).html().toUpperCase().indexOf(term) === -1
        && $(tech).html().toUpperCase().indexOf(term) === -1
        ) {
        $(collection[i]).hide();
      } else {
        $(collection[i]).show();
      };
    };
    }
  });

  $(document).on("turbolinks:load", function(){
    if ($('body[data-controller=inventories][data-action=edit]').length > 0) {
      poller = setInterval(countFetcher, 2000);
    };
    // Inventory#order filter buttons
    $("#item_btn").hide();
    $('#order_supplier_div').hide();
    $('[data-toggle="popover"]').popover();
  });

  // Inventory#edit auto-updating poller
  $(document).on('click', '#cancel_polling', function() {
    clearInterval(poller);
    console.log('Stopped polling');
    $('#count_refresh_message').html('Live refresh is stopped.');
    $(this).toggle();
    $('#start_polling').toggle();
  });

  $(document).on('click', '#start_polling', function() {
    // make sure poller is not running
    clearInterval(poller);
    poller = setInterval(countFetcher, 2000);
    console.log('Started polling');
    $('#count_refresh_message').html('Live refresh is running.');
    $(this).toggle();
    $('#cancel_polling').toggle();
  });

  // Inventory#order filter buttons
  $(document).on("click", "#supplier_btn", function() {
    $("#order_item_div").hide();
    $("#item_ttl").hide();
    $(this).hide();
    $("#order_supplier_div").show();
    $("#supplier_ttl").show();
    $("#item_btn").show();
    event.preventDefault();
  });

  $(document).on("click", "#item_btn", function() {
    $("#order_supplier_div").hide();
    $("#supplier_ttl").hide();
    $(this).hide();
    $("#order_item_div").show();
    $("#item_ttl").show();
    $("#supplier_btn").show();
    event.preventDefault();
  });

  // Inventory#order checkbox buttons && checkboxes
  $(document).on("click", ".btn-check", function() {
    var idStr = $(this).attr("id");
    var split = idStr.split("_");
    // Some combo of ["check", "all"] and ["uncheck", "id"]
    toggleCheck(split[0],split[1]);
    event.preventDefault();
  });

  $(document).on("change", ".order_checkbox", function() {
    twinSnyc(this);
    orderTotal();
  });

  // Inventory#order form field
  $(document).on("change", ".min-order-field", function() {
    lineTotal(this);
    lineCheck(this);
    reformat(this);
    orderTotal();
  });
}());
