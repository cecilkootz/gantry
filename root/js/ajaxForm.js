/**
 *
 * Gantry: ajaxForm.js
 *
 * Contains functions to display / render gantry forms using ajax.
 *
 * Author John Weigel [John.Weigel at knology dot com]
 * Copyright (C) 2011 Knology
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 1 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

var $j = jQuery.noConflict();
var blocking = false;
var gantryAjaxFormBuiCss;
var gantryAjaxErrorFormBuiCss;
var gantryAjaxFormOptions = {};

$j(document).ready(function() {
    var offset = $j("#results").offset();
    var top = 140;
    var left = 150;

    // Set css defaults for bui popup form.
    gantryAjaxFormBuiCss = {
        top: top,
        left: offset.left + left,
        width: '425px',
        border: '1px solid #000',
        backgroundColor: '#ccc',
        '-webkit-border-radius': '10px',
        '-moz-border-radius': '10px',
        opacity: '1',
        color: '#000'
    };

    // Set css defaults for bui popup error form.
    gantryAjaxErrorFormBuiCss = {
        width: '300px',
        border: 'none',
        padding: '15px',
        backgroundColor: '#000',
        '-webkit-border-radius': '10px',
        '-moz-border-radius': '10px',
        opacity: '.8',
        color: '#fff'
    };

    /**
    *
    * function:     $j.address.change(fn)
    *
    * parameters:   event
    *
    * description:  Method that gets called when navigation changes occur.
    *                 event object contains the following:
    *                 value            - url including query string.
    *                 path            - url minus the query string.
    *                 pathNames        - comma separated list of each part of the path.
    *                 parameterNames    - comma separated list of parameter names.
    *                 parameters        - object containing parameter values.
    *                 queryString        - url query string.
    *
    */
    $j.address.change(function(event) {
        if (event.value == '/') {
            if (blocking == true) {
                $j.unblockUI();
            }
        }
        else {
            gantryAjaxDisplayForm(event.path, event.parameters.gftype, event.parameters.eftype);
        }
    });
});

/**
*
* function:     gantryAjaxRenderForm(formType, json)
*
* parameters:   formType, json
*
* description:  Given the type of form (currently bui or inline) and a json
*                 representation of a gantry form, it will render the form
*                 to the page. bui type forms use the blockUI jquery plugin
*                 to create a blocking popup form. Inline forms will replace
*                 the content on the page with output of the form.
*/
function gantryAjaxRenderForm (formType, json) {
    var fieldsets = [];
    var cfsgroup = {};
    var jform = $j(
        $j.sprintf(
            '<form action="%s" method="post" class="form-box">' +
                '<div class="form-box">' +
                '</div>' +
            '</form>',
            json.form.action
        )
    );
    var ajaxFormOptions = {
        'dataType'        :    'json',
        'success'        :    function (result_json, status_text) {
                                // Response contains a form...
                                if (result_json.form != null) {
                                    // Set form action to original form action if none was specified.
                                    if (result_json.form.action == null) {
                                        result_json.form.action = json.form.action;
                                    }

                                    gantryAjaxRenderForm(formType, result_json);
                                }
                                // Response contains results.
                                else if (result_json.headings != null) {
                                    gantryAjaxRenderResults(result_json);
                                    $j.address.value('/');
                                }
                                else {
                                    $j.address.value('/');
                                }
                            },
    };

    // Add any specified callbacks to the options.
    for (var cb in gantryAjaxFormOptions) {
        alert(cb);
        ajaxFormOptions[cb] = gantryAjaxFormOptions[cb];
    }

    // Handle form error summary.
    if (json.form.results != null && json.form.show_error_summary == 1) {
        if (json.form.results.msgs.group_by_field == 1) {
            var invalid = false;
            var missing = false;

            // Check for invalid.
            for (var i in json.form.results.invalid) {
                invalid = true;
            }

            // Check for missing.
            for (var i in json.form.results.missing) {
                missing = true;
            }

            // If there are any invalid or missing fields...
            if (invalid || missing) {
                var jep = $j('<p class="missing" style="color: red"></p>');

                for (var i = 0; i < json.form.fields.length; i++) {
                    var field = json.form.fields[i];

                    if (json.form.results.invalid[field.name] || json.form.results.missing[field.name]) {
                        jep.append(
                            $j.sprintf(
                                '<b>%s:</b> %s<br />',
                                field.label,
                                json.form.results.msgs[field.name]
                            )
                        );
                    }
                }

                jform.prepend(jep);
            }
        }
    }

    // Init cfsgroup.
    cfsgroup.legend = 'gantry-default';
    cfsgroup.fields = [];

    // Output any message contained in the form.
    if (json.form.message != null) {
        jform.find('div').append(
            $j.sprintf(
                '<div class="msg">%s</div>',
                json.form.message
            )
        );
    }

    if (json.form.fields != null) {
        // Foreach over the fields and add them to the fieldset.
        for (var i = 0; i < json.form.fields.length; i++) {
            var field = json.form.fields[i];

            if (field.fieldset != null && field.fieldset != cfsgroup.legend) {
                if (cfsgroup.fields.length > 0) {
                    fieldsets.push(cfsgroup);
                }

                cfsgroup = {};
                cfsgroup.fields = [];
                cfsgroup.legend = field.fieldset;
                cfsgroup.fields.push(field);
            }
            else {
                cfsgroup.fields.push(field);
            }
        }

        // Add last fieldset.
        fieldsets.push(cfsgroup);

        // Loop over the fieldsets created above.
        for (var i = 0; i < fieldsets.length; i++) {
            var fieldset = fieldsets[i];
            var jfs = $j(
                $j.sprintf(
                    '<fieldset class="%s"></fieldset>',
                    fieldset.legend.replace(/ /g, '').replace("'", '').toLowerCase()
                )
            );

            // Loop over the fields in the fieldset.
            for (var f = 0; f < fieldset.fields.length; f++) {
                var field = fieldset.fields[f];
                var jlabel = $j(
                    $j.sprintf(
                        '<label id="%s_label">%s%s</label>',
                        field.name,
                        field.label,
                        (field.optional != 1 ? ' *' : '')
                    )
                );

                // Determine label class based on if the field is optional or not.
                if (field.optional != 1) {
                    jlabel.addClass('required');
                }

                // Set 'for' attribute for all types except display and html.
                if (field.type != 'display' && field.type != 'html') {
                    jlabel.attr('for', field.name);
                }

                // Add the label to the fieldset unless the field type is hidden.
                if (field.type != 'hidden') {
                    jfs.append(jlabel);
                }

                // Handle file type fields.
                if (field.type == 'file') {
                    // Add the file input to the fieldset.
                    jfs.append(
                        $j.sprintf(
                            '<input type="file" name="%s" />',
                            field.name
                        )
                    );
                }
                // Handle display type fields.
                else if (field.type == 'display') {
                    var fieldDisplay;

                    // Get the display value from either the row or the default value.
                    if (json.form.row != null && json.form.row[field.name] != null) {
                        fieldDisplay = json.form.row[field.name];
                    }
                    else {
                        fieldDisplay = field.default_value;
                    }

                    // Add the display div to the fieldset.
                    jfs.append(
                        $j.sprintf(
                            '<div class="display">%s</div>',
                            fieldDisplay
                        )
                    );
                }
                // Handle textarea type fields.
                else if (field.type == 'textarea') {
                    var val                = '';
                    var jtextarea;

                    // Determine val.
                    if (field.name in json.params) {
                        val = json.params[field.name];
                    }
                    else if (json.form.row != null) {
                        val = json.form.row[field.name];
                    }
                    else {
                        val = field.default_value;
                    }

                    // Create textarea.
                    jtextarea = $j(
                        $j.sprintf(
                            '<%s name="%s" id="%s">%s</%s>',
                            field.type,
                            field.name,
                            field.name,
                            val,
                            field.type
                        )
                    );

                    // Determine field class if any.
                    if (field['class'] != null) {
                        jtextarea.addClass(field['class']);
                    }

                    // Determine field rows if any.
                    if (field['rows'] != null) {
                        jtextarea.attr('rows', field['rows']);
                    }

                    // Determine field cols if any.
                    if (field['cols'] != null) {
                        jtextarea.attr('cols', field['cols']);
                    }

                    // Determine if disabled.
                    if (field['disabled'] == 1) {
                        jtextarea.attr('disabled', 'disabled');
                    }

                    // Add textarea field.
                    jfs.append(jtextarea);
                }
                // Handle select and multiple select type fields.
                else if (field.type == 'select' || field.type == 'multiple_select') {
                    var selected        = {};
                    var jselect = $j(
                        $j.sprintf(
                            '<select name="%s" id="%s"></select>',
                            field.name,
                            field.name
                        )
                    );

                    // Determine if any options are selected.
                    if (json.params[field.name] != null) {
                        if (json.params[field.name] instanceof Array) {
                            for (var p = 0; p < json.params[field.name].length; p++) {
                                selected[json.params[field.name][p]] = true;
                            }
                        }
                        else {
                            selected[json.params[field.name]] = true;
                        }
                    }
                    else if (json.form.row != null && json.form.row[field.name] != null) {
                        selected[json.form.row[field.name]] = true;
                    }
                    else {
                        selected[field.default_value] = true;
                    }

                    // Determine field class if any.
                    if (field['class'] != null) {
                        jselect.addClass(field['class']);
                    }

                    // Determine field size if any.
                    if (field['display_size'] != null) {
                        jselect.attr('size', field['display_size']);
                    }

                    // Determine if disabled.
                    if (field['disabled'] == 1) {
                        jselect.attr('disabled', 'disabled');
                    }

                    // Determine on change if any.
                    if (field['onchange'] != null) {
                        jselect.attr('onchange', field['onchange']);
                    }

                    // Determine if this is a multi select.
                    if (field['type'] == 'multiple_select') {
                        jselect.attr('multiple', 'multiple');
                    }

                    // Add options to the select list.
                    for (var opt = 0; opt < field.options.length; opt++) {
                        var option = field.options[opt];
                        var joption = $j(
                            $j.sprintf(
                                '<option value="%s">%s</option>',
                                option.value,
                                option.label
                            )
                        );

                        // Determine if current option should be selected.
                        if (selected[option.value]) {
                            joption.attr('selected', 'selected');
                        }

                        // Add option to select element.
                        jselect.append(joption);
                    }

                    // Add select to fieldset.
                    jfs.append(jselect);
                }
                else if (field.type == 'html') {
                    jfs.append(field.html);
                }
                // Handle all other type fields.
                else {
                    var val;
                    var jinput;

                    // Determine val.
                    if (field.name in json.params) {
                        val = json.params[field.name];
                    }
                    else if (json.form.row != null) {
                        val = json.form.row[field.name];
                    }
                    else if (field.default_value != null) {
                        val = field.default_value;
                    }

                    // Create input.
                    jinput = $j(
                        $j.sprintf(
                            '<input type="%s" name="%s" id="%s" />',
                            field.type,
                            field.name,
                            field.name
                        )
                    );

                    // Determine field class if any.
                    if (field['class'] != null) {
                        jinput.addClass(field['class']);
                    }

                    // Determine field size if any.
                    if (field['display_size'] != null) {
                        jinput.attr('size', field['display_size']);
                    }

                    // Determine field value if any.
                    if (val != null) {
                        jinput.attr('value', val);
                    }

                    // Determine if disabled.
                    if (field['disabled'] == 1) {
                        jinput.attr('disabled', 'disabled');
                    }

                    // Add input field.
                    jfs.append(jinput);
                }

                if (field.type != 'hidden') {
                    // Add field hint.
                    jfs.append(
                        $j.sprintf(
                            '<span id="%s_hint" class="hint">%s</span>',
                            field.name,
                            (field.hint != null ? field.hint : '')
                        )
                    );

                    // If we have results...
                    if (json.form.results != null) {
                        // Display invalid span if necessary.
                        if (json.form.results.invalid[field.name] != null) {
                            jfs.append(' <span class="invalid">invalid</span>');
                        }

                        // Display missing span if necessary.
                        if (json.form.results.missing[field.name] != null) {
                            jfs.append(' <span class="missing">required</span>');
                        }
                    }

                    jfs.append(
                        $j.sprintf(
                            '<br id="%s_br" style="clear: both" />',
                            field.name
                        )
                    );
                }
            }

            // Add the legend unless its the gantry default legend.
            if (fieldset.legend != 'gantry-default') {
                jfs.prepend(
                    $j.sprintf(
                        '<legend>%s</legend>',
                        fieldset.legend
                    )
                );
            }

            // Add the fieldset to the form.
            jform.find('div').append(jfs);
        }
    }

    // Output actions box if we have a submit or cancel action.
    if (json.form.no_submit != 1 || json.form.no_cancel != 1) {
        var jactionsDiv = $j(
            $j.sprintf(
                '<div class="form-box actions"></div>'
            )
        )

        // Add additional form class if necessary.
        if (json.form['class'] != null) {
            jactionsDiv.addClass(json.form['class']);
        }


        // Add submit button.
        if (json.form.no_submit != 1) {
            jactionsDiv.append(
                $j.sprintf(
                    '<input type="submit" name="submit_button" id="submit_button" value="%s" />',
                    (json.form.submit_button_label ? json.form.submit_button_label : 'Submit')
                )
            );
        }

        // Add submit and add another button.
        if (json.form.submit_and_add_another == 1) {
            var value = (
                json.form.submit_and_add_another_label
                ? json.form.submit_and_add_another_label
                : 'Submit &amp; Add Another'
            );

            jactionsDiv.append(
                $j.sprintf(
                    '<input type="submit" name="submit_add_another" ' +
                    'id="submit_add_another" value="%s" />',
                    (
                        json.form.submit_and_add_another_label
                        ? json.form.submit_and_add_another_label
                        : 'Submit &amp; Add Another'
                    )
                )
            );
        }

        // Add cancel button.
        if (json.form.no_cancel != 1) {
            var value = (
                json.form.cancel_button_label
                ? json.form.cancel_button_label
                : 'Cancel'
            );

            jactionsDiv.append(
                $j.sprintf(
                    '<input type="submit" name="cancel" id="cancel" value="%s" />',
                    (
                        json.form.cancel_button_label
                        ? json.form.cancel_button_label
                        : 'Cancel'
                    )
                )
            );
        }

        // Add actions_div to form.
        jform.append(jactionsDiv);
    }

    // Output form header unless its not wanted.
    if (json.form.nohead != 1) {
        jform.find('div:first').prepend(
            $j.sprintf(
                '<h4 class="heading">%s</h4>',
                json.title
            )
        );
    }

    // Add ajax to form.
    jform.ajaxForm(ajaxFormOptions);

    // Handle inline forms.
    if (formType == 'inline') {
        $j('#content').html('');
        $j('#content').prepend(jform);
    }
    // Handle blockUI popup forms.
    else if (formType == 'bui') {
        var offset = $j("#results").offset();
        var top = 140;
        var left = 150;
        var buiPopup = $j(
            $j.sprintf(
                '<div class="bui-popup">' +
                    '<div class="bui-header">' +
                        '<div class="heading">%s</div>' +
                        '<div class="bui-close"></div>' +
                        '<div style="clear: both;"></div>' +
                    '</div>' +
                    '<div class="bui-body"></div>' +
                    '<div class="bui-footer"></div>' +
                '</div>',
                json.title
            )
        );

        // Add form to body.
        buiPopup.find('.bui-body').prepend(jform);

        // Add click handler to close button to go back.
        buiPopup.find('.bui-close').click( function() {
            history.go(-1);
            return false;
        });

        // Add click handler to cancel button to go back.
        buiPopup.find('.form-box.actions>input[id=cancel]').click( function() {
            history.go(-1);
            return false;
        });

        // Call blockUi to display message.
        $j.blockUI( {
            message: buiPopup,
            css: gantryAjaxFormBuiCss
        });

        blocking = true;
    }
}

/**
*
* function:     gantryAjaxDisplayForm(ajaxLocation, formType, errorType)
*
* parameters:   ajaxLocation, formType, errorType
*
* description:  This function queries the specfied ajaxLocation for a json
*                representation of a gantry form. If no error occurs retrieving
*                the form then it will call gantryAjaxRenderForm to handle
*                the actual rendering of the form. Their are two supported form
*                types. bui will use the blockUI jquery plugin to create a popup
*                form. inline will output the form to the content section of the page.
*                If errorType is set to bui, then any errors that occur while retrieving
*                the form will be displayed using a popup windows created created using
*                the jquery blockUI plugin. If not specified, it will create an alert
*                window to display errors.
*
*/
function gantryAjaxDisplayForm (ajaxLocation, formType, errorType) {
    // Put error handler in place for json requests returning non 200 responses.
    $j.ajaxSetup({"error": function(XMLHttpRequest,textStatus, errorThrown) {
        var json = eval('(' + XMLHttpRequest.responseText + ')');

        if (errorType = 'bui') {
            var jerror = $j(
                $j.sprintf(
                    '<div id="error">' +
                        '<div>An error has occured:</div>' +
                        '<div id="error_msg">%s</div>' +
                        '<div id="error_continue">Continue</div>' +
                    '</div>',
                    json.error
                )
            );

            // Add click handler for continue button.
            jerror.find('#error_continue').click( function() {
                history.go(-1);
                $j.unblockUI();
                return false;
            });

            // Create a modal dialog to present the error.
            $j.blockUI( {
                message: jerror,
                css: gantryAjaxErrorFormBuiCss
            });
        }
        else {
            alert(json.error);
        }
    }});

    // Make get json request.
    $j.getJSON(
        ajaxLocation,
        function (json) {
            if (json.error) {
                if (errorType = 'bui') {
                    var jerror = $j(
                        $j.sprintf(
                            '<div id="error">' +
                                '<div>An error has occured:</div>' +
                                '<div id="error_msg">%s</div>' +
                                '<div id="error_continue">Continue</div>' +
                            '</div>',
                            json.error
                        )
                    );

                    // Add click handler for continue button.
                    jerror.find('#error_continue').click( function() {
                        history.go(-1);
                        $j.unblockUI();
                        return false;
                    });

                    // Create a modal dialog to present the error.
                    $j.blockUI( {
                        message: jerror,
                        css: gantryAjaxErrorFormBuiCss
                    });
                }
                else {
                    alert(json.error);
                }
            }
            else {
                // Set form action to ajaxLocation if none was specified.
                if (json.form.action == null) {
                    json.form.action = ajaxLocation;
                }

                // Render the form.
                gantryAjaxRenderForm(formType, json);
            }
        }
    );
}
