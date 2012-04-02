# -*- encoding : utf-8 -*-
module QuestionsHelper
  
  def lastSituationsFields(field_name)
    parts = []
    parts << "<p>Игрок1: "+text_field_tag(field_name+'_player1')+"<span id='#{field_name}_player1_error'/></p></p>"
    parts << "<p>Игрок2: "+text_field_tag(field_name+'_player2')+"<span id='#{field_name}_player2_error'/></p>"
    parts << "<p>Игрок3: "+text_field_tag(field_name+'_player3')+"<span id='#{field_name}_player3_error'/></p>"
    parts << %Q{<script type="text/javascript">
                  jQuery(document).ready(function() {
                  var field1 = new LiveValidation( '#{field_name}_player1', {insertAfterWhatNode: "#{field_name}_player1_error" } );
                  field1.add( Validate.Presence );
                  field1.add( Validate.Numericality, { minimum: 0, maximum: 100 } );
                  var field2 = new LiveValidation( '#{field_name}_player2', {insertAfterWhatNode: "#{field_name}_player2_error" } );
                  field2.add( Validate.Presence );
                  field2.add( Validate.Numericality, { minimum: 0, maximum: 100 } );
                  var field3 = new LiveValidation( '#{field_name}_player3', {insertAfterWhatNode: "#{field_name}_player3_error" } );
                  field3.add( Validate.Presence );
                  field3.add( Validate.Numericality, { minimum: 0, maximum: 100 } );
                  });
                  
                </script>}
    parts.join("").html_safe
  end
  
end
