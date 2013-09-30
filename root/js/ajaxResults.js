/**
 *
 * Gantry: ajaxResults.js
 *
 * Contains functions to display / render gantry results using ajax.
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

/**
*
* function:     buildOptions(jobj, options)
*
* parameters:   jobj, options
*
* description:  This function will build the jquery options object for gantry
*                 result tables. This includes both pre header, header, and row
*                 options.
*/
function buildOptions (jobj, options) {
    // Loop over all the header options.
    for (var i = 0; i < options.length; i++) {
        var option = options[i];

        // Output left bracket on first iteration.
        if (i == 0) {
            jobj.append('[ ');
        }

        // If a link was specfied for the option...
        if (option.link != null || option.rel != null) {
            var anchor = $j(
                $j.sprintf(
                    '<a>%s</a>',
                    option.text
                )
            );

            // Add href to anchor.
            if (option.link != null) {
                anchor.attr('href', option.link);
            }

            // Add rel attribute to anchor.
            if (option.rel) {
                anchor.attr('rel', option.rel);
            }

            // Add anchor to jquery object.
            jobj.append(anchor);
        }
        // Add the option text without any link.
        else {
            jobj.append(option.text);
        }

        // Add a separator if its not the last option.
        if (i != options.length - 1) {
            jobj.append(' | ');
        }
        // Add closing bracket after last option.
        else {
            jobj.append(' ]');
        }
    }
}

/**
*
* function:     gantryAjaxRenderResults(json)
*
* parameters:   json
*
* description:  Given a json representation of a gantry result table,
*                 this method will render the results to the content section
*                 of the page.
*/
function gantryAjaxRenderResults (json) {
    var $j = jQuery.noConflict();
    var resultsBox = $j(
        $j.sprintf(
            '<div class="box">' +
                '<table id="%s" class="%s">' +
                    '<thead>' +
                    '</thead>' +
                    '<tbody>' +
                    '</tbody>' +
                '</table>' +
            '</div>',
            ( json.id ? json.id : 'results'),
            'results ' + ( json['class'] != null ? json['class'] : '' )
        )
    );
    var colspan = ( json.headings != null ? json.headings.length : 0 );
    var altBG = 1;
    var hdrRow;

    // Add 1 to colspan if there are options.
    if (json.no_options != 1) {
        colspan += 1;
    }

    // If pre headings are not disabled...
    if (json.no_pre_headings != 1) {
        var preheadingRow = $j('<tr class="pre-hdr-row"></tr>');
        var hidePreHeadings = ( json.params != null && json.params.hide_preheadings == 1 ? 'true' : 'false' );
        var phocolspan = colspan;

        // Check if there are table preheadings to output.
        if (json.pre_headings != null && json.pre_headings.length > 0 && ! hidePreHeadings) {
            var preHeadingClass = '';

            for (var i = 0; i < json.pre_headings.length; i++) {
                var preHeading = json.pre_headings[i];
                var colspanAttr = '';
                var preHeadingText;
                var td;

                // Pre heading is an object.
                if (typeof preHeading == 'object') {
                    if (preHeading.colspan != null && preHeading.colspan > 0) {
                        colspanAttr    = 'colspan="' + preHeading.colspan + '"';
                        phocolspan    -= preHeading.colspan;
                    }

                    preHeadingText    = preHeading.text;
                    preHeadingClass    = preHeading['class'];
                }
                // Pre heading is just text.
                else {
                    preHeadingText = preHeading;
                }

                // Create pre heading jquery td object with the correct
                // class, colspan, and text.
                td = $j(
                    $j.sprintf(
                        '<td class="%s" %s>' +
                            '%s' +
                        '</td>',
                        'hdr ' + preHeading['class'],
                        colspanAttr,
                        preHeadingText
                    )
                );

                preHeadingRow.append(td);
            }

            // Add options if there are any.
            if (json.pre_header_options.length > 0) {
                var tdOpt = $j('<td class="rhdr"></td>');

                // Add additional class if it exists.
                if (json.pre_header_options['class']) {
                    tdOpt.addClass(json.pre_header_options['class']);
                }

                // Build the options.
                 buildOptions(tdOpt, json.pre_header_options);

                // Add options cell to header row.
                preHeadingRow.append(tdOpt);
            }
        }
        // Add empty preheading row.
        else {
            preheadingRow.append(
                $j.sprintf(
                    '<td class="hdr" colspan="%s">&nbsp;</td>',
                    colspan
                )
            );
        }

        resultsBox.find('thead').append(preheadingRow);
    }

    // Create header row.
    hdrRow = $j('<tr class="hdr-row"></td>');

    // Add columns to header row.
    for (var i = 0; i < json.headings.length; i++) {
        var heading = json.headings[i];
        var th = $j('<th class="hdr"></th>');

        // heading is an object...
        if (typeof heading == 'object') {
            // Add additional class.
            if (heading['class'] != null) {
                th.addClass(heading['class']);
            }

            // Add title.
            if (heading['title'] != null) {
                th.attr('title', heading['title']);
            }

            // Add text.
            th.html(heading['text']);
        }
        // heading is just text...
        else {
            th.html(heading);
        }

        // Add th to header row.
        hdrRow.append(th);
    }

    // Add header options unless no_options is set.
    if (json.no_options != 1) {
        var thOpt = $j('<th class="rhdr"></th>');

        // Add additional class if it exists.
        if (json.header_options['class']) {
            thOpt.addClass(json.header_options['class']);
        }

        // Build the options.
        buildOptions(thOpt, json.header_options);

        // Add options cell to header row.
        hdrRow.append(thOpt);
    }

    // Add header row.
    resultsBox.find('thead').append(hdrRow);

    if (json.rows != null && json.rows.length > 0) {
        // Foreach over the table rows...
        for ( var i = 0; i < json.rows.length; i++) {
            var row = json.rows[i];
            var tr = $j('<tr class="results-row"></tr>');

            // Add id to row.
            if (row.id != null) {
                tr.attr('id', row.id);
            }

            // Unless the row class matches (warning|highlighted)-row then add
            // the standard alt-bgx class.
            if (row['class'] == null || (row['class'] != null && ! row['class'].match(/(warning|highlighted)-row/i))) {
                tr.addClass('alt-bg' + altBG);
            }

            // Add any additional class.
            if (row['class'] != null) {
                tr.addClass(row['class']);
            }

            // Foreach over the data items in the row...
            for ( var e = 0; e < row.data.length; e++) {
                var elem = row.data[e];
                var td = $j('<td class="dta"></td>');

                // If we have an object...
                if (typeof elem == 'object') {
                    // Add id to td if it exists.
                    if (elem['class'] != null) {
                        td.attr('id', elem['class']);
                    }

                    // Add additional class if it exists.
                    if (elem['class'] != null) {
                        td.addClass(elem['class']);
                    }

                    // Add style if it exists.
                    if (elem['td_style'] != null) {
                        var style = elem['td_style'];

                        style.replace(/^style="|"$/ig);

                        td.attr('style', style);
                    }

                    // Add colspan if it exists.
                    if (elem['colspan'] != null) {
                        td.attr('colspan', elem['colspan']);
                    }

                    // Add element text.
                    td.html(elem['text']);
                }
                // elem is not an object so just add the text.
                else {
                    td.html(elem);
                }

                // Add last class if this is the last row in the table.
                if (i == json.rows.length - 1) {
                    td.addClass('last');
                }

                // Add the column to the row.
                tr.append(td);
            }

            // Add row options if necessary.
            if (json.no_options != 1) {
                var tdOpt = $j('<td class="rdta"></td>');
                var optClasses = [];

                // Add id if it exists.
                if (row.options['id']) {
                    tdOpt.attr('id', row.options['id']);
                }

                // Add additional class if it exists.
                if (row.options['class']) {
                    tdOpt.addClass(row.options['class']);
                }

                // Add last class if this is the last row in the table.
                if (i == json.rows.length - 1) {
                    tdOpt.addClass('last');
                }

                // Add style if it exists.
                if (row.options['td_style'] != null) {
                    var style = row.options['td_style'];

                    style.replace(/^style="|"$/ig);

                    tdOpt.attr('style', style);
                }

                // Build the options.
                buildOptions(tdOpt, row.options);

                // Add options cell to header row.
                tr.append(tdOpt);
            }

            // Add row to table body.
            resultsBox.find('tbody').append(tr);

            // Switch bg color.
            altBG = ( altBG == 1 ? 0 : 1 );
        }
    }
    // No row data found...
    else {
        resultsBox.find('tbody').append(
            $j.sprintf(
                '<tr class="no-data"><td colspan="%s">No Data</td></tr>',
                colspan
            )
        );
    }

    // Clear content and add resultsBox.
    $j('#content').html('');
    $j('#content').prepend(resultsBox);
}
