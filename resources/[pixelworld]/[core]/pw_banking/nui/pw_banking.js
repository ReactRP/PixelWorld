var Config = new Object();
Config.closeKeys = [69];
var playerData = null;
var bankDetails = null;
var currentData = null;

window.addEventListener("message", function (event) {
    if(event.data.action == "openBankingTerminal") {
        playerData = event.data.playerData;
        bankDetails = event.data.bank;
        currentData = event.data.data;
        setupInitialBanking(true);
    }
    if(event.data.action == "closeBankingTerminal") {
        $('#bankingContainer').fadeOut(1000);
        playerData = null;
        bankDetails = null;
        currentData = null;
    }
    if(event.data.action == "updatePlayerData") {
        playerData = event.data.playerData;
        toggleQuickButtons();
    }
    if(event.data.action == "updateBanking") {
        currentData = event.data.data;
        setupInitialBanking(false);
    }
    if(event.data.action == "savingsOpened") {
        $('#savingsNewAccountNumber').html(currentData.savings.accountdetails.account_number);
        $('#savingsNewSortCode').html(currentData.savings.accountdetails.sort_code);
        $('#savingsNewIban').html(currentData.savings.accountdetails.iban);
        $('#openSavingsConfirmed').modal('toggle');

        
    }
    if(event.data.action == "externalTransferMessage") {
        if(event.data.error == "success") {
            $('#accountNumberTransfer').val('');
            $('#sortCodeTransfer').val('');
            $('#transferExtAmount').val('');
        }
        $('#externalTransferErrorMsg').removeClass('alert-success').removeClass('alert-danger').addClass('alert-' + event.data.error).html(event.data.message);
        $('#externalTransferError').css({"display":"block"});
        setTimeout(function(){ 
            $('#externalTransferErrorMsg').removeClass('alert-success').removeClass('alert-danger').html('');
            $('#externalTransferError').css({"display":"none"});
         }, 5000);
    }
    if(event.data.action == "externalChangePinMessage") {
        if(event.data.alert == "success") {
            $('#newDebitCardPin1').removeClass('is-invalid').removeClass('is-valid');
            $('#oldDebitCardPin').removeClass('is-invalid').removeClass('is-valid'); 
            $('#oldDebitCardPin').val('');
            $('#newDebitCardPin1').val('');
        }
        $('#changePinAlert').html(event.data.message);
        $('#changePinAlert').addClass('alert-'+event.data.alert).fadeIn(500);
        setTimeout(function() {
            $('#changePinAlert').fadeOut(500);
            setTimeout(function() {
                $('#changePinAlert').html('').removeClass('alert-'+event.data.alert);
                if(event.data.alert == "success") {
                    setTimeout(function() {
                        $('#changePinNumber').modal('hide');
                    }, 200);
                }
            }, 501);
        }, 3000);
    }
});

function clearScreen() {
    $('#v-pills-home-tab').removeClass('active');
    $('#v-pills-transfers-tab').removeClass('active');
    $('#v-pills-loans-tab').removeClass('active');
    $('#v-pills-statement-tab').removeClass('active');
    $('#v-pills-debitcards-tab').removeClass('active');
    $('#v-pills-home').removeClass('active').removeClass('show');
    $('#v-pills-transfers').removeClass('active').removeClass('show');
    $('#v-pills-loans').removeClass('active').removeClass('show');
    $('#v-pills-statement').removeClass('active').removeClass('show');
    $('#v-pills-debitcards').removeClass('active').removeClass('show');
    // Set Default Homescreen
    $('#v-pills-home-tab').addClass('active');
    $('#v-pills-home').addClass('active').addClass('show');
}

function toggleQuickButtons() {
    if(currentData.personal.balance < 10000) {
        $('#qwit10000').addClass('disabled');
    } else {
        $('#qwit10000').removeClass('disabled');
    }
    if(currentData.personal.balance < 1000) {
        $('#qwit1000').addClass('disabled');
    } else {
        $('#qwit1000').removeClass('disabled');
    }
    if(currentData.personal.balance < 100) {
        $('#qwit100').addClass('disabled');
    } else {
        $('#qwit100').removeClass('disabled');
    }
    if(currentData.personal.balance < 10) {
        $('#qwit10').addClass('disabled');
    } else {
        $('#qwit10').removeClass('disabled');
    }

    if(playerData.cash < 10000) {
        $('#qdep10000').addClass('disabled');
    } else {
        $('#qdep10000').removeClass('disabled');
    }
    if(playerData.cash < 1000) {
        $('#qdep1000').addClass('disabled'); 
    } else {
        $('#qdep1000').removeClass('disabled');
    }
    if(playerData.cash < 100) {
        $('#qdep100').addClass('disabled');
    } else {
        $('#qdep100').removeClass('disabled');
    }
    if(playerData.cash < 10) {
        $('#qdep10').addClass('disabled');
    } else {
        $('#qdep10').removeClass('disabled');
    }

    if(currentData.savings.exist === true) {
        if(currentData.savings.balance < 10000) {
            $('#1qwit10000').addClass('disabled');
        } else {
            $('#1qwit10000').removeClass('disabled');
        }
        if(currentData.savings.balance < 1000) {
            $('#1qwit1000').addClass('disabled');
        } else {
            $('#1qwit1000').removeClass('disabled');
        }
        if(currentData.savings.balance < 100) {
            $('#1qwit100').addClass('disabled');
        } else {
            $('#1qwit100').removeClass('disabled');
        }
        if(currentData.savings.balance < 10) {
            $('#1qwit10').addClass('disabled');
        } else {
            $('#1qwit10').removeClass('disabled');
        }
    
        if(currentData.personal.balance < 10000) {
            $('#1qdep10000').addClass('disabled');
        } else {
            $('#1qdep10000').removeClass('disabled');
        }
        if(currentData.personal.balance < 1000) {
            $('#1qdep1000').addClass('disabled');
        } else {
            $('#1qdep1000').removeClass('disabled');
        }
        if(currentData.personal.balance < 100) {
            $('#1qdep100').addClass('disabled');
        } else {
            $('#1qdep100').removeClass('disabled');
        }
        if(currentData.personal.balance < 10) {
            $('#1qdep10').addClass('disabled');
        } else {
            $('#1qdep10').removeClass('disabled');
        }
    }
}

function dynamicSort(property) {
    var sortOrder = 1;
    if(property[0] === "-") {
        sortOrder = -1;
        property = property.substr(1);
    }
    return function (a,b) {
        var result = (a[property] < b[property]) ? -1 : (a[property] > b[property]) ? 1 : 0;
        return result * sortOrder;
    }
}

function space(str, stp, rev) {
    if (!str) {
        return false;
    }
    if (rev == 1) {
        str = str.split('').reverse().join('');
    }
    if(stp > 0) {
        var v = str.replace(/[^\dA-Z]/g, ''),
            reg = new RegExp(".{" + stp + "}", "g");
        str = v.replace(reg, function (a) {
            return a + ' ';
        });
    }
    if (rev == 1) {
        str = str.split('').reverse().join('');
    }
    return str;
}

function setupInitialBanking(toggle) {
    $('#overdraftEligable').css({"display":"none"});
    $('#transferFrom').html('');
    $('#transferTo').html('');
    $("#savingsStatement").DataTable().destroy();
    $("#currentStatement").DataTable().destroy();
    if(toggle === true) {
        clearScreen();
    }
    $('[data-content=playerName]').html('');
    $('#currentBalance').html('');
    $('#currentAccountNumber').html('');
    $('#currentSortCode').html('');
    $('#currentIBAN').html('');
    $('#bankName').html('');
    $('#currentOverDraft').html('');
    var currentScore = ((currentData.creditScore / 1000) * 100);
    $('#creditScoreProgress').css({"width":"" + currentScore + "%"});
    $('#scoreText').html(currentData.creditScore);

    if(currentData.personal.meta.overdraft == undefined && currentData.creditScore > 650 || currentData.personal.meta.overdraft == 0 && currentData.creditScore > 650 || currentData.personal.meta.overdraft == null && currentData.creditScore > 650) {
        var overDraftOffer = ((currentData.creditScore / 2) * 3);
        $('#overdraftOffer').html(Math.floor(overDraftOffer));
        $('#overdraftEligable').css({"display":"block"});
    }

    if(currentData.savings.exist === true) {
        $('#transferFrom').append('<option value="cash">Cash</option><option value="current">Current Account</option><option value="savings">Savings Account</option>"')
        $('#transferTo').append('<option value="cash">Cash</option><option value="current">Current Account</option><option value="savings">Savings Account</option>"')
        $('#savings-tab').removeClass('disabled');
        $('#savingsQuickActions').css({"display":"block"});
        $('#savingsDetails').html('');
        $('#savingsBalance').html('$'+currentData.savings.balance);
        $('#savingsDetails').html('<strong>Account Number:</strong> ' + currentData.savings.accountdetails.account_number + '<br><strong>Sort Code:</strong> ' + currentData.savings.accountdetails.sort_code + '<br><strong>IBAN:</strong> '+ currentData.savings.accountdetails.iban);
        if(currentData.savings.statement !== undefined) {
            $("#savingsStatementContents").html('');
            var savingsstatement = currentData.savings.statement
            savingsstatement.sort(dynamicSort("date"));
            $.each(savingsstatement, function (index, statement) {
                if(statement.deposited == null && statement.deposited == undefined) {
                    deposit = "0"
                } else {
                    deposit = statement.deposited
                }
                if(statement.withdraw == null && statement.withdraw == undefined) {
                    withdraw = "0"
                } else {
                    withdraw = statement.withdraw
                }
                if (statement.balance == 0) {
                    balance = '<span class="text-dark">$' + statement.balance + '</span>';
                } else if(statement.balance > 0) {
                    balance = '<span class="text-success">$' + statement.balance + '</span>';
                } else {
                    balance = '<span class="text-danger">$' + statement.balance + '</span>';
                }
                $("#savingsStatementContents").append('<tr class="statement"><td><small>' + statement.date + '</small></td><td><small>' + statement.message + '</small></td><td class="text-center text-danger"><small>$' + withdraw + '</small></td><td class="text-center text-success"><small>$' + deposit + '</small></td><td class="text-center"><small>' + balance + '</small></td></tr>');
        
            });

            $(document).ready(function() {
                $('#savingsStatement').DataTable({
                    "order": [[ 0, "desc" ]],
                    "pagingType": "simple"
                });
            } );
        }

    } else {
        $('#transferFrom').append('<option value="cash">Cash</option><option value="current">Current Account</option>"')
        $('#transferTo').append('<option value="cash">Cash</option><option value="current">Current Account</option>"')
        $('#savings-tab').addClass('disabled');
        $('#savingsQuickActions').css({"display":"none"});
        $('#savingsBalance').html('Not Opened');
        $('#savingsDetails').html('You do not currently have a savings account.<br><button class="btn btn-info btn-block mt-2" data-toggle="modal" data-target="#openSavingsConfirm">Open Account</button>');
    }
    $('#v-pills-debitcards').html('');
    if(currentData.cardsexist === true) {
        $('#v-pills-debitcards').append('<div class="container-fluid mt-2 p-2"><div class="row"><div class="col-12 text-right p-2"><button class="btn btn-success" data-act="requestNewCard" data-toggle="modal" data-target="#requestNewCardModal">Request New Card</button></div></div><div class="row mt-2 mb-2"><div class="col-12 p-2 rounded" style="background:rgba(255,255,255,0.6);">Here you can manage every aspect to all debit cards assigned to your account, when you lock a card, no transactions can be made from the card until its unlocked, If you report it stolen, the card will be locked, blocked and deleted within 24 hours, you can not undo the report stolen process.</div></div><div class="row justify-content-center" id="debitCardsContent"></div></div>');
        var cards = currentData.cards
        $.each(cards, function (index, card) {
            var Info = JSON.parse(card.cardmeta);
            var lockState = null;
            var stolenState = null;
            var lockText = null;
            var stolenText = null;
            var disabled = null;
            if(Info.stolen === true) {
                disabled = "disabled"; 
                stolenState = "danger"; 
                stolenText = "Blocked";
                lockState = "danger"; 
                lockText = "Locked";
                lockDiv = '';
                stolenDiv = '<div style="position:absolute; height: 194px; width: 300px; top:60px; z-index:101; left:35px; line-height:194px;" class="text-center"><i class="fad fa-siren-on fa-10x" style="color:rgba(255,174,0,0.9);"></i></div>'; 
            } else { 
                stolenDiv = '';
                disabled = '';
                stolenState = "success"; 
                stolenText = "Report Stolen"; 
                if(Info.locked === true) { 
                    lockState = "danger"; 
                    lockText = "Locked"; 
                    lockDiv = '<div style="position:absolute; height: 194px; width: 300px; top:40px; z-index:100; left:35px; line-height:194px;" class="text-center"><i class="fad fa-lock-alt fa-10x" style="color:rgba(255,0,0,0.8);"></i></div>'; 
                } else { 
                    lockState = "success"; 
                    lockText = "Unlocked"; 
                    lockDiv = ''; 
                }
            }
            $('#debitCardsContent').append('<div class="col-4"><div class="card m-2" style="background-color: transparent !important; border: 0px !important;">' + lockDiv + stolenDiv +'<div style="position:absolute; top: 108px; left: 120px; font-size:20px; color: #ffffff;">' + space(card.cardnumber, 4, 1) + '<br></div><div style="position:absolute; top:160px; left:39px; font-size:20px; color:#ffffff;"><span>' + playerData.name + '</span><br><small><small>Sort Code:' + space(Info.sortcode.toString(), 2, 1) + '&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; Account: ' + Info.account + '</div><img src="' + card.type + '.png" class="card-img-top" alt="..."><div class="card-body text-center"><button class="btn btn-sm btn-' + lockState + ' ' + disabled + ' m-1" data-card="' + card.record_id + '" data-act="lockCard">' + lockText + '</button><button class="btn btn-sm btn-' + stolenState + ' ' + disabled + ' m-1" data-card="' + card.record_id + '" data-act="stolenCard">' + stolenText + '</button><button class="btn btn-sm btn-info ' + disabled + ' m-1" data-card="' + card.record_id + '" data-act="changePin" data-pin="' + Info.cardPin + '">Change Pin</button></div></div></div>');
        });


    } else {
        $('#v-pills-debitcards').append('<div class="container-fluid mt-2 p-2 rounded"><div class="row justify-content-center"><div class="col-4"><div class="card bg-light mb-3"><div class="card-header">No Debit Cards on Account</div><div class="card-body"><p class="card-text"><small>You do not currently have any debit cards associated with your account, click below to be issued one.</small></p><div class="w-100 text-center"><i class="fad fa-plus-square fa-5x" data-act="createDebitCard" data-toggle="modal" data-target="#requestNewCardModal"></i></div></div></div></div></div></div>')
        
    }


    if(currentData.personal.statement !== undefined) {
        $("#currentStatementContents").html('');
        var currentStatement = currentData.personal.statement;
        $.each(currentStatement, function (index, statement) {
            if(statement.deposited == null && statement.deposited == undefined) {
                deposit = "0"
            } else {
                deposit = statement.deposited
            }
            if(statement.withdraw == null && statement.withdraw == undefined) {
                withdraw = "0"
            } else {
                withdraw = statement.withdraw
            }
            if (statement.balance == 0) {
                balance = '<span class="text-dark">$' + statement.balance + '</span>';
            } else if (statement.balance > 0) {
                balance = '<span class="text-success">$' + statement.balance + '</span>';
            } else {
                balance = '<span class="text-danger">$' + statement.balance + '</span>';
            }
            $("#currentStatementContents").append('<tr class="statement"><td><small>' + statement.date + '</small></td><td><small>' + statement.message + '</small></td><td class="text-center text-danger"><small>$' + withdraw + '</small></td><td class="text-center text-success"><small>$' + deposit + '</small></td><td class="text-center"><small>' + balance + '</small></td></tr>');
    
        });

        $(document).ready(function() {
            $('#currentStatement').DataTable({
                "order": [[ 0, "desc" ]],
                "pagingType": "simple",
                "lengthMenu": [[20, 35, 50, -1], [20, 35, 50, "All"]]
            });
        } );
    }


    $('#bankName').html(bankDetails.name);
    $('[data-content=playerName]').html(playerData.name);
    $('#currentBalance').html(currentData.personal.balance);
    $('#currentAccountNumber').html(currentData.personal.accountdetails.account_number);
    $('#currentSortCode').html(currentData.personal.accountdetails.sort_code);
    $('#currentIBAN').html(currentData.personal.accountdetails.iban);
    $('#currentOverDraft').html(currentData.personal.meta.overdraft);
    $('#bankingContainer').fadeIn(1000);
    setTimeout(function(){ 
        toggleQuickButtons();
    }, 100);
}

function closeBanking() {
    $('#openSavingsConfirmed').modal('hide');
    $('#changePinNumber').modal('hide');
    $('#requestNewCardModal').modal('hide');
    $.post("http://pw_banking/NUIFocusOff", JSON.stringify({}));
}

$( function() {
        
    $("body").on("keydown", function (key) {
        if (Config.closeKeys.includes(key.which)) {
            closeBanking();
        }
    });

    $(document).on('auxclick', 'a', function(e) {
        if (e.which === 2) { //middle Click
            e.preventDefault();
            e.stopPropagation();
            e.stopImmediatePropagation();
            return false;
        }
        return true;
    });

    $(document).on('click','[data-act=closeBankingWindow]',function(){
        closeBanking();
    });

    $(document).on('click','[data-act=lockCard]',function(){
        if(!$(this).hasClass('disabled')) {
            var card = $(this).data('card');
            $.post("http://pw_banking/lockCard", JSON.stringify({
                card: card,
            }));
        }
    });

    $(document).on('click','[data-act=stolenCard]',function(){
        if(!$(this).hasClass('disabled')) {
            var card = $(this).data('card');
            $.post("http://pw_banking/stolenCard", JSON.stringify({
                card: card,
            }));
        }
    });

    $(document).on('click','[data-act=changePin]',function(){
        if(!$(this).hasClass('disabled')) {
            var card = $(this).data('card');
            var pin = $(this).data('pin');
            $('#requestCardButton1').data('card', card);
            $('#requestCardButton1').data('pin', pin);
            $('#changePinNumber').modal('toggle');
        }
    });
    
    $(document).on('click','[data-act=quickwithdraw]',function(){
        if(!$(this).hasClass('disabled')) {
            $(this).addClass('disabled');
            var amount = parseInt($(this).data('amount'));
            var account = $(this).data('account');
            $.post("http://pw_banking/quickTransfer", JSON.stringify({
                type: "withdraw",
                amount: amount,
                account: account
            }));
        }
    });

    $(document).on('click','[data-act=quickdeposit]',function(){
        if(!$(this).hasClass('disabled')) {
            $(this).addClass('disabled');
            var amount = parseInt($(this).data('amount'));
            var account = $(this).data('account');
            $.post("http://pw_banking/quickTransfer", JSON.stringify({
                type: "deposit",
                amount: amount,
                account: account
            }));
        }
    });

    $(document).on('click','[data-act=completeInternalTransfer]',function(){
        if(!$(this).hasClass('disabled')) {
            var from = $('#transferFrom').val();
            var to = $('#transferTo').val();
            var amount = $('#transferAmount').val();
            if(from !== undefined && from !== "" && to !== undefined && to !== "" && amount !== undefined && amount !== "" && amount > 0 && to !== from) {
                $('#internalTransferErrorMsg').removeClass('alert-danger').addClass('alert-success').html('Your request has been successful.');
                $('#internalTransferError').css({"display":"block"});
                $.post("http://pw_banking/completeInternalTransfer", JSON.stringify({
                    from: from,
                    to: to,
                    amount: amount
                }));
                $('#transferFrom').val('Please Select');
                $('#transferTo').val('Please Select');
                $('#transferAmount').val('');
                setTimeout(function(){ 
                    $('#internalTransferErrorMsg').removeClass('alert-success').removeClass('alert-danger').html('');
                    $('#internalTransferError').css({"display":"none"});
                 }, 5000);
            } else {
                $('#internalTransferErrorMsg').removeClass('alert-success').addClass('alert-danger').html('There is an error with your request');
                $('#internalTransferError').css({"display":"block"});
            }
        }
    });

    $(document).on('click','[data-act=requestCardButton]',function(){
        if(!$(this).hasClass('disabled')) {
            $('#requestNewCardModal').modal('toggle');
            var pinnumber = $('#newDebitCardPin').val().toString();
            $('#newDebitCardPin').val('');
            $.post("http://pw_banking/createDebitCard", JSON.stringify({
                pin: pinnumber
            }));
        }
    });

    $(document).on('click','[data-act=completeExternalTransfer]',function(){
        if(!$(this).hasClass('disabled')) {
            var accountnumber = $('#accountNumberTransfer').val();
            var sortcode = $('#sortCodeTransfer').val();
            var amount = $('#transferExtAmount').val();

            if(accountnumber !== undefined && accountnumber !== "" && sortcode !== undefined && sortcode !== "" && amount !== undefined && amount !== "" && amount > 0) {
                var accountText = accountnumber.toString();
                var sortcodeText = sortcode.toString();
                if(accountText.length !== 8) {
                    $('#externalTransferErrorMsg').addClass('alert-danger').removeClass('alert-success').html('The specified account number is not 8 digits long.');
                    $('#externalTransferError').css({"display":"block"});
                } else if(sortcodeText.length !== 6) {
                    $('#externalTransferErrorMsg').addClass('alert-danger').removeClass('alert-success').html('The specified sort code is not 6 digits long.');
                    $('#externalTransferError').css({"display":"block"});
                } else {
                    $('#externalTransferErrorMsg').removeClass('alert-danger').removeClass('alert-success').html('');
                    $('#externalTransferError').css({"display":"none"});
                    // This is where we want to send the post request
                    $.post("http://pw_banking/completeExternalTransfer", JSON.stringify({
                        accountnumber: accountnumber,
                        sortcode: sortcode,
                        amount: amount
                }));
                }
            } else {
                $('#externalTransferErrorMsg').addClass('alert-danger').removeClass('alert-success').html('There was an error processing your payment request.');
                $('#externalTransferError').css({"display":"block"});
            }

        };
    }); 

    $('#accountNumberTransfer').on('keyup', function() {
        var amount = $(this).val();
        var text = amount.toString();
        if (text.length === 0) {
            $('#accountNumberError').html('');
        } else if (text.length !== 8) {
            $('#accountNumberError').html('<small>Account Numbers must be 8 digits long excately.</small>');
        } else {
            $('#accountNumberError').html('');
        }
    })

    
    $(document).on('click','[data-act=confirmChangePin]',function(){
        var currentPin = $(this).data('pin');
        var currentCard = $(this).data('card');
        var oldPin = $('#oldDebitCardPin').val();
        var newPin = $('#newDebitCardPin1').val();
        if(!$(this).hasClass('disabled')) {
            if(oldPin == currentPin) {
                if(oldPin == currentPin && oldPin != newPin && oldPin.length === 4 && newPin.length === 4) {
                    $.post("http://pw_banking/changePin", JSON.stringify({
                        oldPin: oldPin,
                        newPin: newPin,
                        currentPin: currentPin,
                        card: currentCard
                    }));
                } else {
                    $('#changePinAlert').html('There has been a error processing your request, you pin must be 4 digits long, and not be the same as your old pin.');
                    $('#changePinAlert').addClass('alert-danger').fadeIn(500);
                    setTimeout(function() {
                        $('#changePinAlert').fadeOut(500);
                        setTimeout(function() {
                            $('#changePinAlert').html('').removeClass('alert-danger');
                        }, 501);
                    }, 4500);
                }
            } else {
                $('#changePinAlert').html('Your current pin does not match what you entered.');
                $('#changePinAlert').addClass('alert-danger').fadeIn(500);
                setTimeout(function() {
                    $('#changePinAlert').fadeOut(500);
                    setTimeout(function() {
                        $('#changePinAlert').html('').removeClass('alert-danger');
                    }, 501);
                }, 2500);
            }
        }
    });


    $('#newDebitCardPin1').on('keyup', function() {
        var pin = $(this).val();
        if (pin.length === 4) {
            $('#newDebitCardPin1').removeClass('is-invalid').addClass('is-valid');
        } else if (pin.length !== 4) {
            $('#newDebitCardPin1').addClass('is-invalid').removeClass('is-valid');
            $('#confirmChangePin').addClass('disabled');
        }

        var oldPinLength = $('#oldDebitCardPin').val();
        var newPinLength = $('#newDebitCardPin1').val();
        if(oldPinLength.length === newPinLength.length) {
            if(newPinLength.length === 4 && oldPinLength.length === 4 && oldPinLength != newPinLength) { 
                $('#requestCardButton1').removeClass('disabled');
            } else {
                $('#requestCardButton1').addClass('disabled');    
            }
        } else {
            $('#requestCardButton1').addClass('disabled');
        }
    })

    $('#oldDebitCardPin').on('keyup', function() {
        var pin = $(this).val();
        if (pin.length === 4) {
            var newPinLength = $('#newDebitCardPin1').val().toString();
            $('#oldDebitCardPin').removeClass('is-invalid').addClass('is-valid');           
        } else if (pin.length !== 4) {
            $('#oldDebitCardPin').addClass('is-invalid').removeClass('is-valid');
        }

        var oldPinLength = $('#oldDebitCardPin').val()
        var newPinLength = $('#newDebitCardPin1').val()
        if(oldPinLength.length === newPinLength.length) {
            if(newPinLength.length === 4 && oldPinLength.length === 4 && oldPinLength != newPinLength) {
                $('#requestCardButton1').removeClass('disabled');
            } else {
                $('#requestCardButton1').addClass('disabled');    
            }
        } else {
            $('#requestCardButton1').addClass('disabled');
        }
    })


    $('#newDebitCardPin').on('keyup', function() {
        var pin = $(this).val();
        if (pin.length === 4) {
            $('#newDebitCardPin').removeClass('is-invalid').addClass('is-valid');
            $('#requestCardButton').removeClass('disabled');
        } else if (pin.length !== 4) {
            $('#newDebitCardPin').addClass('is-invalid').removeClass('is-valid');
            $('#requestCardButton').addClass('disabled');
        }
    })

    $('#sortCodeTransfer').on('keyup', function() {
        var amount = $(this).val();
        var text = amount.toString();
        if (text.length === 0) {
            $('#sortCodeError').html('');
        } else if (text.length !== 6) {
            $('#sortCodeError').html('<small>Sort Codes must be 6 digits long excately.</small>');
        } else {
            $('#sortCodeError').html('');
        }
    })

    $(document).on('click','[data-act=openSavingsConfirm]',function(){
        $.post("http://pw_banking/requestOpenSavings", JSON.stringify({}));
    });

})