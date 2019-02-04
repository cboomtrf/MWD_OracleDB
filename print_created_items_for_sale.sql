/**
 * Follow instructions on below url to ensure that Oracle Net listener can accept HTTP requests
 * https://docs.oracle.com/cd/B28359_01/appdev.111/b28424/adfns_web.htm#i1006207
 * Then run this procedure with the url: http://host:port/plsql/print_created_items_for_sale
**/

CREATE OR REPLACE PROCEDURE print_created_items_for_sale IS
  CURSOR item_cursor IS
    SELECT i.name, c.created_item_type, i.description, i.list_price, i.current_amount
      FROM items i,
	  created_items c
	  where c.item_id = i.id
	  and i.item_type = 'CREATED_ITEM'
	  and i.sale_status = 'FOR_SALE'
        ORDER BY i.name;
BEGIN
  HTP.PRINT('<html>');
  HTP.PRINT('<head>');
  HTP.PRINT('<meta http-equiv="Content-Type" content="text/html">');
  HTP.PRINT('<title>List of Employees</title>');
  HTP.PRINT('</head>'); 
  HTP.PRINT('<body TEXT="#000000" BGCOLOR="#FFFFFF">');
  HTP.PRINT('<h1>List of Employees</h1>');
  HTP.PRINT('<table width="40%" border="1">');
  HTP.PRINT('<tr>');
  HTP.PRINT('<th align="left">Name</th>');
  HTP.PRINT('<th align="left">Item Type</th>');
  HTP.PRINT('<th align="left">Description</th>');
  HTP.PRINT('<th align="left">Price</th>');
  HTP.PRINT('<th align="left">Amount available</th>');
  HTP.PRINT('</tr>');
  FOR item_record IN item_cursor LOOP
    HTP.PRINT('<tr>');
    HTP.PRINT('<td>' || item_record.name  || '</td>');
	HTP.PRINT('<td>' || item_record.created_item_type || '</td>');
    HTP.PRINT('<td>' || item_record.description || '</td>');
    HTP.PRINT('<td>' || item_record.list_price || '</td>');
	HTP.PRINT('<td>' || item_record.current_amount || '</td>');
	END LOOP;
  HTP.PRINT('</table>');
  HTP.PRINT('</body>');
  HTP.PRINT('</html>');
END print_created_items_for_sale;
/
