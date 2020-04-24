var Config = new Object();
Config.closeKeys = [27];
var clientPin = null;
var cardNumber = null;
var accountNo = null;
var sortCode = null;

window.addEventListener("message", function (event) {    
    if(event.data.status == "openChipPin") {

    } else if(event.data.status == "closePin") {
        $("#pinContainer").css({"display":"none"});
        $("#companyName").css({"display":"none"});
        $("#compName").html('')
        $('#cardSelector').css({"display":"none"});
    } else if(event.data.status == "populateCards") {
        $('#pinCode').val('');
        $("#compName").html('');
        $("#companyName").css({"display":"none"});
        $('#acceptButton').data('triggertype', event.data.type);
        $('#acceptButton').data('trigger', event.data.trigger);
        populateCurrentCards(event.data);
        $('#cardSelector').css({"display":"block"});
    }
});

function populateCurrentCards(data) {
    $('#cardsDisplay').html('');
    $.each(data.cards, function(index, card) {
        if(card.item == "visacard") {
            image = "visa.png"
        } else {
            image = "mastercard.png"
        }
        cardJson = jQuery.parseJSON(card.metapublic);
        var str = ""+ cardJson.cardnumber + "";
        var res = str.slice(12);
        var cardNumber = "************" + res;
        if(card.active !== undefined && card.active !== null && card.active === true) {
            cardStatus = '<span class="text-success">(Active)</span> ';
        } else {
            cardStatus = '';
        }
        $('#cardsDisplay').append('<div class="card mb-3 mx-auto" style="width:100%;"><div class="row no-gutters"><div class="col-2 my-auto text-center"><img src="images/' + image + '" class="img-fluid" width="100" alt=""></div><div class="col-8"><div class="card-body p-0"><h5 class="card-title pb-0 pt-1 pl-2 mb-0" id="cardOwner-' + index + '">' + card.owner_name +'</h5><p class="card-text pl-2"><small class="text-muted"><span id="cardType-' + index + '">' + cardStatus + '' + card.card_type + '</span><br><span id="cardNumber-' + index + '">' + cardNumber + '</span></small></p></div></div><div class="col-2 my-auto pr-1"><button class="btn btn-primary btn-sm btn-block" id="cardBtn-' + index + '" data-action="useCard">Use</button></div></div></div>');
        $('#cardBtn-' + index).data('card', card);
        if(data.reqamount !== undefined && data.reqamount !== null) {
            $('#cardBtn-' + index).data('transactionDetails', data.reqamount)
        }
        if(data.data !== undefined && data.data !== null) {
            $('#cardBtn-' + index).data('data', data.data);
        }

    });
}

function closeTerminal() {
    clientPin = null;
    cardNumber = null;
    accountNo = null;
    sortCode = null;
    $.post("http://pw_debitcard/NUIFocusOff", JSON.stringify({}));
}

$( function() {
    $("body").on("keydown", function (key) {
        if (Config.closeKeys.includes(key.which)) {
            closeTerminal();
        }
    });

    $("#cancel").click(function() {
        $('#pinCode').val('');
        closeTerminal();
    });

    $("#cancelTransaction").click(function() {
        closeTerminal();
    });

    $(document).on('click','[data-action=useCard]',function(){
        var cardInformation = $(this).data('card');
        var transactionDetails = $(this).data('transactionDetails');
        var otherData = $(this).data('data')
        cardJsonPub = jQuery.parseJSON(cardInformation.metapublic);
        cardJsonPri = jQuery.parseJSON(cardInformation.metaprivate);
        clientPin = cardInformation.cardmeta.cardPin;
        cardNumber = cardJsonPri.cardnumber;
        accountNo = cardInformation.cardmeta.account;
        sortCode = cardInformation.cardmeta.sortcode;
        console.log(cardNumber);

        if(transactionDetails !== undefined && transactionDetails !== null) {
            if(transactionDetails.amount !== undefined && transactionDetails.amount !== null) {
                $('#acceptButton').data('amount', transactionDetails.amount);
                $('#amount1').html(transactionDetails.amount);
                $('#amount2').html(transactionDetails.amount);
                if(transactionDetails.statement !== undefined && transactionDetails.statement !== null) {
                    $('#acceptButton').data('statement', transactionDetails.statement);
                }
            }
            if(transactionDetails.to !== undefined && transactionDetails.to !== null) {
                $("#compName").html(transactionDetails.to)
                $("#companyName").css({"display":"block"});
            }
        }

        if(otherData !== undefined && otherData !== null) {
            $('#acceptButton').data('data', otherData);
        }

        $('#cardSelector').css({"display":"none"});
        $("#pinContainer").css({"display":"block"});
        
    });

    $("[data-act=enterNumber]").click(function() {
        var number = $(this).data('number');
        if (number == "ACCEPT") {
            var currentVal = $('#pinCode').val();
            if (currentVal == clientPin) {
                var anyData = $('#acceptButton').data('data');
                var statement = $('#acceptButton').data('statement');
                if (statement == undefined || statement == null) {
                    statement = "Payment for $" + amount;
                }
                var trigger = $('#acceptButton').data('trigger');
                var triggerType = $('#acceptButton').data('triggertype');
                var amount = $('#acceptButton').data('amount');
                if (statement == undefined || statement == null) {
                    statement = "Payment for $" + amount + " to " + $("#compName").html(transactionDetails.to);
                }
                $('#errorMsg').addClass('alert-info').removeClass('alert-danger');
                $('#errorMsg').html('Please enter your debit card pin, to authorise a purchase using your debit card.');
                var pinEntered = $('#pinCode').val(); 
                $.post("http://pw_debitcard/pinSuccess", JSON.stringify({
                    trigger: trigger,
                    triggerType: triggerType,
                    data: anyData,
                    amount: amount,
                    enteredPin: pinEntered,
                    cardNumber: cardNumber,
                    accountNo: accountNo,
                    sortCode: sortCode,
                    statement: statement
                }));
                closeTerminal();
                $('#pinCode').val('');
            } else {
                $('#pinCode').val('');
                $('#errorMsg').removeClass('alert-info').addClass('alert-danger');
                $('#errorMsg').html('You have entered an incorrect pin, please try again.')
                setTimeout(function(){ 
                    $('#errorMsg').addClass('alert-info').removeClass('alert-danger');
                    $('#errorMsg').html('Please enter your debit card pin, to authorise a purchase using your debit card.');
                }, 5000);
            }
        } else if (number == "CLEAR") {
            $('#pinCode').val('');
        } else if (number == "CANCEL") {
            closeTerminal();
        } else {
            var currentVal = $('#pinCode').val();
            $('#pinCode').val(currentVal+number);
        }
    });


});