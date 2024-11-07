#
#Hierarchy widget
#

package SynSemClassHierarchy::Hierarchy;
use base qw(SynSemClassHierarchy::FramedWidget);

require Tk::Tree;
require Tk::HList;
require Tk::ItemStyle;
use utf8;

sub create_widget {
  my ($self, $data, $field, $top, @conf) = @_;

  my $w = $top->Frame(-takefocus => 0);
  $w->configure(@conf) if (@conf);
  $w->pack(qw/-side top -pady 4 -expand yes -fill both/);

  my $hic_frame = $w->Frame(-takefocus=>0);
  $hic_frame->pack(qw/-side top -expand yes -fill both/);

  my $hierarchylabel_frame = $hic_frame->Frame(-takefocus=>0);
  $hierarchylabel_frame->pack(qw/-fill both/);

  $hierarchylabel_label = $hierarchylabel_frame->Label(-text => "Hierarchy concepts", qw/-anchor nw -justify left/)->pack(qw/-side left -padx 4 -fill x/);
  
  my $hierarchybutton_frame=$hierarchylabel_frame->Frame(-takefocus=>0);
  $hierarchybutton_frame->pack(qw/-side right -padx 4/);

  my $modify_hic_button = $hierarchybutton_frame->Button(-text=>'Modify', -underline=>0, -command=>[\&modify_hic_button_pressed, $self])->pack(qw/-side right -fill x/);
  my $move_hic_button = $hierarchybutton_frame->Button(-text=>'Move', -underline=>2, -command=>[\&move_hic_button_pressed, $self])->pack(qw/-side right -fill x/);
  my $un_delete_hic_button = $hierarchybutton_frame->Button(-text=>'(Un)delete', -underline=>4, -command=>[\&un_delete_hic_button_pressed, $self])->pack(qw/-side right -fill x/);
  my $add_hic_button = $hierarchybutton_frame->Button(-text=>'Add', -underline=>0, -command=>[\&add_hic_button_pressed, $self])->pack(qw/-side right -fill x/);
  my $set_hic_button = $hierarchybutton_frame->Button(-text=>'Set', -underline=>0, -command=>[\&set_hic_button_pressed, $self])->pack(qw/-side right -fill x/);


  my $hierarchy_tree = $hic_frame->Scrolled(qw/Tree -separator \/
	  											-columns 2
	  											-background white
	  											-width 35
												-height 25
												-selectmode single
												-scrollbars osoe /) -> pack( qw/-expand yes -fill both -padx 4 -side top/ );

  $hierarchy_tree->configure(-browsecmd => [\&hic_item_changed, $self]);
  
  $hierarchy_tree->bind('<v>', sub { $self->move_hic_button_pressed(); });
  $hierarchy_tree->bind('<m>', sub { $self->modify_hic_button_pressed(); });
  $hierarchy_tree->bind('<d>', sub { $self->un_delete_hic_button_pressed(); });
  $hierarchy_tree->bind('<a>', sub { $self->add_hic_button_pressed(); });
  $hierarchy_tree->bind('<s>', sub { $self->set_hic_button_pressed(); });

  my $hic_balloon = $hic_frame->Balloon(-balloonposition=>'mouse');

  my $buttons_for_concepts_frame = $hic_frame->Frame(-takefocus=>0);
  $buttons_for_concepts_frame->pack(qw/-fill both/);
  my $deleted_concepts_visibility_button = $buttons_for_concepts_frame->Checkbutton(-text => "Show deleted Concepts", 
															-command => [\&deleted_concepts_visibility_button_pressed, $self]);

  $deleted_concepts_visibility_button->pack(qw/-fill both -side left -padx 4/);
  my $hic_classes_frame = $hic_frame->Frame(-takefocus=>0)->pack( qw/-expand yes -fill x -padx 4 -pady 20 -side left/ );
  
  my $hic_classeslabel_frame = $hic_classes_frame->Frame(-takefocus=>0);
  $hic_classeslabel_frame->pack(qw/-fill both/);

  my $hic_classeslabel_label = $hic_classeslabel_frame->Label(-text => "Classes for selected concept: ", qw/-anchor nw -justify left/)->pack(qw/-side left -padx 4 -fill x/);

  my $hic_classesbutton_frame = $hic_classeslabel_frame->Frame(-takefocus=>0);
  $hic_classesbutton_frame->pack(qw/-side right -padx 4/);
  my $modify_note_for_class_button = $hic_classesbutton_frame->Button(-text=>'Note', -underline=>0, -command=>[\&modify_note_for_class_button_pressed, $self])->pack(qw/-side right -fill x/);
  my $change_hic_for_class_button = $hic_classesbutton_frame->Button(-text=>'Change concept', -underline=>0, -command=>[\&change_hic_for_class_button_pressed, $self])->pack(qw/-side right -fill x/);
  my $hic_classes_list = $hic_classes_frame->Scrolled(qw/Tree -columns 3
	  										-background white
											-header 1
											-width 35
											-height 25
											-selectmode single
											-scrollbars osoe /)->pack( qw/-expand yes -fill both -padx 4 -side top/ );

  $hic_classes_list->configure(-command => [\&open_class_info_link, $self]);
  $hic_classes_list->configure(-browsecmd => [\&hic_classes_item_changed, $self]);

  $hic_classes_list->bind('<c>', sub { $self->change_hic_for_class_button_pressed(); });
  $hic_classes_list->bind('<n>', sub { $self->modify_note_for_class_button_pressed(); });
 
 
  my $hic_class_classmembers_frame = $hic_frame->Frame(-takefocus=>0)->pack( qw/-expand yes -fill x -padx 4 -pady 20 -side left/ );
  
  my $hic_class_classmembers_label = $hic_class_classmembers_frame->Label(-text => "Classmembers for selected class: ", qw/-anchor nw -justify left/)->pack(qw/-side top -padx 4 -fill both/);
  my $hic_class_classmembers_list = $hic_class_classmembers_frame->Scrolled(qw/HList -columns 2
	  										-background white
											-header 1
											-width 35
											-height 25
											-selectmode single
											-scrollbars osoe /) -> pack( qw/-expand yes -fill both -padx 4 -side top/ );

  $hic_class_classmembers_list->configure(-command => [\&open_classmember_info_link, $self]);

 return $w, {
	 move_hic_button=>$modify_hic_button,
	 modify_hic_button=>$modify_hic_button,
	 un_delete_hic_button=>$un_delete_hic_button,
	 add_hic_button=>$add_hic_button,
	 set_hic_button=>$set_hic_button,
	 hierarchy_tree=>$hierarchy_tree,
	 hic_balloon=>$hic_balloon,
	 hic_classeslabel_label=>$hic_classeslabel_label,
	 change_hic_for_class_button=>$change_hic_for_class_button,
	 modify_note_for_class_button=>$modify_note_for_class_button,
	 hic_classes_list=>$hic_classes_list,
	 hic_class_classmembers_label=>$hic_class_classmembers_label,
	 hic_class_classmembers_list=>$hic_class_classmembers_list
	 
 }, "", "", 0

}

sub set_editor_frame{
  my ($self, $eframe)=@_;
  $self->[4]=$eframe;
}

sub get_editor_frame{
  my ($self) = @_;
  return $self->[4];
}

sub set_selected_class{
  my ($self, $class) = @_;
  $self->[5]=$class;
}

sub get_selected_class{
  my ($self) = @_;
  return $self->[5];
}

sub SHOW_DELETED_CONCEPTS { 6 }

sub deleted_concepts_visibility_button_pressed{
	my ($self) = @_;
	if ($self->[SHOW_DELETED_CONCEPTS]){
		$self->[SHOW_DELETED_CONCEPTS] = 0;
	}else{
		$self->[SHOW_DELETED_CONCEPTS] = 1;
	}
	my $focused_hic = $self->focused_hierarchy_concept();
	my $focused_id = "hic_0";
	if ($focused_hic){
		$focused_id = $focused_hic->[1];
	}
	$self->fetch_data($self->get_selected_class, $focused_id);
}

sub fetch_data {
  my ($self, $class, $anchor_hic) = @_;
  my $t=$self->subwidget("hierarchy_tree");
  my $balloon = $self->subwidget('hic_balloon');
  $t->delete('all');
  $t->selectionClear();
  $balloon->detach($t);
  $self->set_selected_class($class);
  my $data_hierarchy=$self->data->hierarchy;

  my %path_for_concept=();
  my $class_hic = "hic_0";
  if ($class){
	$class_hic = $self->data->main->getClassHierarchyConcept($class) || "hic_0";
  }

  $anchor_hic = $class_hic unless ($anchor_hic);

  my $end_node_style = $t->ItemStyle("imagetext", -foreground => '#2ECC71', -background => 'white', -selectforeground => '#2ECC71');
  my $in_node_style = $t->ItemStyle("imagetext", -foreground => '#3498DB', -background => 'white', -selectforeground => '#3498DB');
  my $node_style = $t->ItemStyle("imagetext", -foreground => 'black', -background => 'white', -selectforeground => 'black');
  my $node_style_canceled = $t->ItemStyle("imagetext", -foreground => 'black', -background => '#FEFEB1', -selectforeground => 'grey');
  my $node_style_deleted = $t->ItemStyle("imagetext", -foreground => 'black', -background => '#FFCCCB', -selectforeground => 'grey');
  
  my $root_node = $data_hierarchy->getRootHierarchyNode;
  my $root_path = $t->add("0", -data=>$root_node);
  my $id = $data_hierarchy->getHierarchyConceptAttribute($root_node, "id");
  my $name = $data_hierarchy->getHierarchyConceptAttribute($root_node, "name");
  my $status = $data_hierarchy->getHierarchyConceptStatus($root_node);
  $t->itemCreate($root_path, 0, -text=>$name);
  $t->itemCreate($root_path, 1, -text=>$id);

  my %balloon_msg = ();
  $path_for_concept{$id}=$root_path;
  my @nodes=($root_node);

  while (scalar @nodes > 0){
	my $node = shift @nodes;
	foreach my $child ($data_hierarchy->getHierarchyChildren($node)){
		my $parent_id = $data_hierarchy->getHierarchyConceptAttribute($node, "id");
		my $parent_path = $path_for_concept{$parent_id};
		my $id = $data_hierarchy->getHierarchyConceptAttribute($child, "id");
		my $name = $data_hierarchy->getHierarchyConceptAttribute($child, "name");
		my $status = $data_hierarchy->getHierarchyConceptStatus($child);
	
		next if (!$self->[SHOW_DELETED_CONCEPTS] and ($status =~ /(moved|deleted)/));
		my $child_path = $t->addchild($parent_path, -data=>[$child]);
		$path_for_concept{$id} = $child_path;
		
		my $style = $node_style;
		if ($anchor_hic eq $id){
			$t->anchorSet($child_path);
			$t->see($child_path);
			$t->selectionSet($child_path);
		}
		if ($class_hic eq $id){
			$style = $end_node_style;	
		} elsif ($data_hierarchy->isAncestor($id, $class_hic)){
			$style = $in_node_style;
		}elsif (($status eq "canceled") or (lc($name) =~ /^(zrušit|cancel)/)){
			$style = $node_style_canceled;
		}elsif($status =~ /(moved|deleted)/){
			$style = $node_style_deleted;
		}
	
		$t->itemCreate($child_path, 0, -text => $name, 
							     	   -style => $style 
						   		);
		$t->itemCreate($child_path, 1, -text => $id, 
						   		 	   -style => $style 
						   		);
		$balloon_msg{$child_path} =$data_hierarchy->getHierarchyConceptDefinition($child) || "Concept $name ($id)"; 
		push @nodes, $child;
		$t->setmode($path, "close");
	}
  }
  $balloon->attach($t, -msg=>\%balloon_msg);
  $self->hic_item_changed();
}

sub set_hic_button_pressed {
	my ($self) = @_;

	my $class = $self->get_selected_class();
	if ($class eq ""){
		SynSemClassHierarchy::Editor::warning_dialog($self, "Select class!");
		return;
	}
	my $old_hic = $self->data->main->getClassHierarchyConcept($class) || "";


	my $focused_hic = $self->focused_hierarchy_concept();
	unless ($focused_hic) {
		SynSemClassHierarchy::Editor::warning_dialog($self, "Select Hierarchy concept!");
		return;
	}

	my $new_hic = $focused_hic->[1];
	
	return if ($old_hic eq $new_hic);

	if (($old_hic ne "") and ($old_hic ne $new_hic)){
		my $answer = SynSemClassHierarchy::Editor::question_dialog($self, "Do you really want to change hierarchy concept \n" . $self->data->hierarchy->getHierarchyConceptNameByID($old_hic) . 
																		"\nto\n" . $self->data->hierarchy->getHierarchyConceptNameByID($new_hic) . "?", "No");
		return if ($answer eq "No");
	}
			
	print "Changing hierarchy concept for class " .  $class->getAttribute("id") . " from "  . $self->data->hierarchy->getHierarchyConceptNameByID($old_hic) . " ($old_hic) to " . $self->data->hierarchy->getHierarchyConceptNameByID($new_hic) . " ($new_hic)\n";
	$self->data->setClassHierarchyConcept($class, $new_hic);
  	$self->get_editor_frame->update_title();
	$self->fetch_data($class);

}

sub add_hic_button_pressed {
	my ($self) = @_;
	
	my $hic = "hic_0";

	my $focused_hic = $self->focused_hierarchy_concept();
	unless ($focused_hic) {
		SynSemClassHierarchy::Editor::warning_dialog($self, "Select Hierarchy concept!");
		return;
	}

	$hic_id = $focused_hic->[1];

	my ($ret_val, $new_hic_id) = $self->addHierarchyConcept($hic_id);
	if ($ret_val == 1){
		$self->fetch_data($self->get_selected_class(), $new_hic_id);
	}

	return 1;
}
sub un_delete_hic_button_pressed {
	my ($self) = @_;
	
	my $focused_hic = $self->focused_hierarchy_concept();
	unless ($focused_hic) {
		SynSemClassHierarchy::Editor::warning_dialog($self, "Select Hierarchy concept!");
		return 1;
	}

	my $hic_name = $focused_hic->[0];
	my $hic_id = $focused_hic->[1];
	my $hic_node = $self->data->hierarchy->getHierarchyNodeByID($hic_id);

	my $hic_node_status = $self->data->hierarchy->getHierarchyConceptStatus($hic_node);

	if ($hic_node_status eq "canceled"){
		my $activity = "delete";
		if ($self->data->usedHierarchySubtree($hic_node)){
			my $answer = SynSemClassHierarchy::Editor::question_dialog($self, "Do you want to set canceled hierarchy concept $hic_name ($hic_id) as active?", "Yes");
			if ($answer eq "Yes"){
				$activity = "active";
			}else{
				SynSemClassHierarchy::Editor::warning_dialog($self, "You can not delete selected hierarchy concept. It (or its subconcepts) is assigned to some class(es).");
				return 0;
			}
		}else{
			my $answer = SynSemClassHierarchy::Editor::question_dialog($self, "Do you want to delete hierarchy concept $hic_name ($hic_id) with all subconcepts?", "Yes"); 
			if ($answer eq "Yes"){
				$activity = "delete";
			}else{
				my $answer = SynSemClassHierarchy::Editor::question_dialog($self, "Do you want to set canceled hierarchy concept $hic_name ($hic_id) as active?", "Yes");
				if ($answer eq "Yes"){
					$activity = "active";
				}else{
					return 1;
				}
			}
		}
		if ($activity eq "active"){
			my $new_name = $hic_name;
			$new_name =~ s/canceled - //;
			my $used_name_node =$self->data->hierarchy->getHierarchyNodeByName($new_name, $hic_id) || "";
			if ($used_name_node ne ""){
				my $used_name_id = $self->data->hierarchy->getHierarchyConceptAttribute($used_name_node, "id");
				SynSemClassHierarchy::Editor::warning_dialog($self, "Name $new_name is already used for the concept with ID $used_name_id. Rename one of them first!"); 
				return 0;
			}
			$self->data->hierarchy->setCanceledHierarchyConceptAsActive($hic_node);
  			$self->get_editor_frame->update_title();
			$self->fetch_data($self->get_selected_class(), $hic_id);
			return 1;
		}elsif ($activity eq "delete"){
			my $h=$self->subwidget('hierarchy_tree');
			my $parentPath  = $h->infoParent($focused_hic->[2]);
			my $parentId = $h->itemCget($parentPath, 1, '-text');
			$self->data->hierarchy->deleteHierarchySubtree($hic_node);
  			$self->get_editor_frame->update_title();
			if ($self->[SHOW_DELETED_CONCEPTS]){
				$self->fetch_data($self->get_selected_class(), $hic_id);
			}else{
				$self->fetch_data($self->get_selected_class(), $parentId);
			}
			return 1;
		}else{
			return 1;
		}
	}elsif( $hic_node_status eq "deleted"){
		my $h=$self->subwidget('hierarchy_tree');
		my $parentPath  = $h->infoParent($focused_hic->[2]);
		my $parentId = $h->itemCget($parentPath, 1, '-text');
		my $parentName = $h->itemCget($parentPath, 0, '-text');
		my $parent_node=$self->data->hierarchy->getHierarchyNodeByID($parentId);
		my $parent_status = $self->data->hierarchy->getHierarchyConceptStatus($parent_node);
		if ($parent_status eq "deleted"){
			SynSemClassHierarchy::Editor::warning_dialog($self, "Subconcept of the deleted concept $parentName ($parentId) can not be set as active concept!");
			return 0;
		}

		my $answer = SynSemClassHierarchy::Editor::question_dialog($self, "Do you really want to set deleted hierarchy concept $hic_name ($hic_id) as active?", "Yes");
		if ($answer eq "Yes"){
			my $new_name = $hic_name;
			$new_name =~ s/deleted - //;
			my $used_name_node =$self->data->hierarchy->getHierarchyNodeByName($new_name, $hic_id) || "";
			if ($used_name_node ne ""){
				my $used_name_id = $self->data->hierarchy->getHierarchyConceptAttribute($used_name_node, "id");
				SynSemClassHierarchy::Editor::warning_dialog($self, "Name $new_name is already used for the concept with ID $used_name_id. Rename one of them first!"); 
				return 0;
			}
			$self->data->hierarchy->setDeletedHierarchyConceptAsActive($hic_node);
  			$self->get_editor_frame->update_title();
			$self->fetch_data($self->get_selected_class(), $hic_id);
			return 1;
		}else{
			return 1;
		}		
	}else{
		if ($self->data->usedHierarchySubtree($hic_node)){
			my $answer = SynSemClassHierarchy::Editor::question_dialog($self, "You can not delete selected hierarchy concept. It (or its subconcepts) is assigned to some class(es). Should I mark it as 'Cancel'?", "Yes");
			if ($answer eq "Yes"){
				$self->data->hierarchy->markHierarchyConceptForCancel($hic_node);
				$self->fetch_data($self->get_selected_class(), $hic_id);
  				$self->get_editor_frame->update_title();
				return 1;
			}else{
				return 1;
			}
		}
	
		my $answer = SynSemClassHierarchy::Editor::question_dialog($self, "Do you really want to delete hierarchy concept $hic_name ($hic_id) with all subconcepts?", "Yes"); 
		if ($answer eq "Yes"){
			my $h=$self->subwidget('hierarchy_tree');
			my $parentPath  = $h->infoParent($focused_hic->[2]);
			my $parentId = $h->itemCget($parentPath, 1, '-text');
			$self->data->hierarchy->deleteHierarchySubtree($hic_node);
			if ($self->[SHOW_DELETED_CONCEPTS]){
				$self->fetch_data($self->get_selected_class(), $hic_id);
			}else{
				$self->fetch_data($self->get_selected_class(), $parentId);
			}
  			$self->get_editor_frame->update_title();
		}
	}

	return 1;
}

sub modify_hic_button_pressed {
	my ($self) = @_;
	
	my $focused_hic = $self->focused_hierarchy_concept();
	unless ($focused_hic) {
		SynSemClassHierarchy::Editor::warning_dialog($self, "Select Hierarchy concept!");
		return;
	}

	$hic_id = $focused_hic->[1];

	if ($self->modifyHierarchyConcept($hic_id)){
		$self->fetch_data($self->get_selected_class(), $hic_id);
  		$self->get_editor_frame->update_title();
	}

	return 1;
}

sub move_hic_button_pressed {
	my ($self) = @_;

	my $focused_hic = $self->focused_hierarchy_concept();
	unless ($focused_hic){
		SynSemClassHierarchy::Editor::warning_dialog($self, "Select Hierarchy concept!");
		return;
	}

	$hic_id = $focused_hic->[1];
	$hic_name= $focused_hic->[0];

	my ($ok, @new_values) = $self->getNewParentForHierarchyConcept("ID", ($hic_id,$hic_name));

	if ($ok){
		if ($hic_id eq $new_values[0]){
			SynSemClassHierarchy::Editor::warning_dialog($self, "New parent Hierarchy Concept can not be selected Concept - no moving!");
			return;
		}
		if ($self->data->hierarchy->isParentHierarchyConcept($new_values[0], $hic_id)){
			SynSemClassHierarchy::Editor::warning_dialog($self, "New parent Hierarchy Concept is the same as the old one - no moving!");
			return;
		}
		if ($self->data->hierarchy->isAncestor($hic_id, $new_values[0])){
			SynSemClassHierarchy::Editor::warning_dialog($self, "New parent Hierarchy concept is the descendant of the selected Hierarchy concept - no moving!");
			return;
		}

		my $answer = SynSemClassHierarchy::Editor::question_dialog($self, "Do you really want to move Hierarchy Concept \n" . $hic_name . " (" . $hic_id . ")\nunder Concept \n" . $new_values[1] . "  (" . $new_values[0] . ")?", "Yes");
		return if ($answer eq "No");
		print "moving Hierarchy concept $hic_name ($hic_id) under " . $new_values[1] . " (" . $new_values[0] . ")\n";
		my $ret_val = $self->data->moveHierarchySubtree($hic_id, $new_values[0]);
		if ($ret_val == 1){
			$self->fetch_data($self->get_selected_class(), $new_values[0]);
  			$self->get_editor_frame->update_title();
		}
	}

	return 1;
}

sub change_hic_for_class_button_pressed{
 	my ($self) = @_;

	my ($self)=@_;
	my $w=$self->subwidget("hic_classes_list");
	my $item = $w->infoAnchor();
	unless (defined $item){
		SynSemClassHierarchy::Editor::warning_dialog($self, "Select class for changing Hierarchy concept!");
		return;
	}
	my $classid = $w->itemCget($item, 0, '-text');
	my $classname = $w->itemCget($item, 1, '-text');
	my $class = $w->infoData($item);

	my $old_hic = $self->data->main->getClassHierarchyConcept($class);
	my $old_name = $self->data->hierarchy->getHierarchyConceptNameByID($old_hic);
	#	print "menim koncept z $old_hic / $old_name\n";
	my @old_values=($old_hic, $old_name);

  	my ($ok, @new_values)=$self->getHierarchyForClass("change class", "ID", @old_values);  
  
	if($ok){
		return if ($new_values[0] eq $old_hic);
		my $answer = SynSemClassHierarchy::Editor::question_dialog($self, "Do you really want to change hierarchy concept for class \n$classname ($classid)\nfrom\n$old_name ($old_hic)\nto\n$new_values[1] ($new_values[0])?", "Yes");
		return if ($answer eq "No");

		print "Changing hierarchy concept for class $classid from $old_name ($old_hic) to $new_values[1] ($new_values[0])\n";
		
		my $ret_val = $self->data->setClassHierarchyConcept($class, $new_values[0]);
		if ($ret_val == 1){
		    $self->data->main->addClassLocalHistory($class, "hierarchy concept changing");
			if (($self->get_selected_class) and ($self->get_selected_class->getAttribute("id") eq $classid)){
				$self->fetch_data($self->get_selected_class(), $old_hic);
			}else{
				$self->hic_item_changed();
  				$self->get_editor_frame->update_title();
			}
		}else{
			my $text = "Can not change hierarchy concept for class $classid. ";
			$text .= " Unknown class." if ($ret_val == -2);
			$text .= " Undefined concept ID $new_values[0]." if ($ret_val == -1);
			SynSemClassHierarchy::Editor::warning_dialog($self, $text);
			print "changing failed ...\n";
		}
  	}
}

sub modify_note_for_class_button_pressed{
	my ($self)=@_;
  
 	my $w=$self->subwidget('hic_classes_list');
 	my $item=$w->infoAnchor();
   
	unless (defined $item){
		SynSemClassHierarchy::Editor::warning_dialog($self, "Select class for changing Class Note!");
		return;
  	}  

	my $classid = $w->itemCget($item, 0, '-text');
	my $classname = $w->itemCget($item, 1, '-text');
	my $class = $w->infoData($item);

	my $oldNote=$self->data->main->getClassNote($class) || "";
  
  	my ($ok, $newNote)=$self->show_note_editor_dialog("Edit note", $oldNote);

	if ($ok and ($oldNote ne $newNote)){
  		$self->data->main->setClassNote($class, $newNote);
	    $self->data->main->addClassLocalHistory($class, "noteModify");
  		$self->get_editor_frame->update_title();
	}
}

sub focused_hierarchy_concept{
	my ($self) = @_;
	
	my $h=$self->subwidget('hierarchy_tree');
	my $t = $h->infoAnchor();
	if (defined($t)){
		return [$h->itemCget($t, 0, '-text'), $h->itemCget($t, 1, '-text'), $t];
	}
	return undef;
}

sub update_hic_classes_classmembers_label{
	my ($self) = @_;
	#DODELAT - pro vybranou tridu
}

sub hic_item_changed{
	my ($self) = @_;

	my $focused_hic_id = "";
	my $focused_hic = $self->focused_hierarchy_concept();
	if (defined $focused_hic){
		$focused_hic_id = $focused_hic->[1];
	}
	$self->fetch_hic_classes($focused_hic_id);
}

sub fetch_hic_classes{
	my ($self, $hic) = @_;
	my $t=$self->subwidget("hic_classes_list");
	my $e;

  	my $item_style = $t->ItemStyle("text", -foreground => 'black', -background => 'white', -selectforeground => 'black');
	$t->delete('all');
	$t->selectionClear();

	$t->headerCreate(0, -itemtype => 'text', -text => "ID");
	my $f_lang = $self->data->main->first_lang || "ces";
	$t->headerCreate(1, -itemtype => 'text', -text => $f_lang . " name");
	$t->headerCreate(2, -itemtype => 'text', -text => "roleset");
	
	if ($hic ne ""){
		my $search_by = "hierarchy_concept:$hic";
		foreach my $entry ($self->data->getClassList($search_by)){
			$e=$t->addchild("", -data=>$entry->[0]);
			$t->itemCreate($e, 0, -itemtype=>'text', -text => $entry->[1], -style => $item_style);
			$t->itemCreate($e, 1, -itemtype=>'text', -text => $entry->[3], -style => $item_style);

			my @roles = $self->data->main->getCommonRolesSLs($entry->[0]);
			my $roleset = join("; ", @roles);
			$t->itemCreate($e, 2, -itemtype=>'text', -text => $roleset, -style => $item_style);
			
		}
	}
	$self->hic_classes_item_changed();
}

sub hic_classes_item_changed{
	my ($self) = @_;
	my $h=$self->subwidget("hic_classes_list");

	my $t = $h->infoAnchor();
	my $selected_class = "";
	if (defined($t)){
		$selected_class =  $h->itemCget($t, 0, '-text');
	}
	$self->fetch_classmembers_for_hic_class($selected_class);
}

sub open_class_info_link{
	my ($self)=@_;
	my $w=$self->subwidget("hic_classes_list");
	my $item = $w->infoAnchor();
	return unless defined($item);
	my $classid = "";
	if (defined $item){
		$classid = $w->itemCget($item, 0, '-text');
	}
	SynSemClassHierarchy::LexLink_All->open_ssc_link($self->data->main, $classid);
}

sub fetch_classmembers_for_hic_class{
	my ($self,$classid) = @_;

	my $t=$self->subwidget("hic_class_classmembers_list");
	my $e;
  	my $item_style = $t->ItemStyle("text", -foreground => 'black', -background => 'white', -selectforeground => 'black');
	$t->delete('all');
	$t->selectionClear();

	$t->headerCreate(0, -itemtype => 'text', -text => "lang");
	$t->headerCreate(1, -itemtype => 'text', -text => "member");
	
	return if ($classid eq "");

	foreach my $lang (@{$self->data->languages()}){
		my $data_cms = $self->data->lang_cms($lang);
		my $class_lang = $data_cms->getClassByID($classid);

		foreach my $entry ($data_cms->getClassMembersList($class_lang)){
			next if ($entry->[3] !~ /yes/);
			$e=$t->addchild("", -data=>[$lang, $entry->[0]]);
			$t->itemCreate($e, 0, -itemtype=>'text', 
								  -text => $lang, 
								  -style => $item_style);
			$t->itemCreate($e, 1, -itemtype=>'text', 
								  -text => $entry->[2] . " (" . $entry->[1] . ")", 
								  -style => $item_style);
		}
	}

}

sub open_classmember_info_link{
	my ($self) = @_;
	my $w=$self->subwidget("hic_class_classmembers_list");
	my $item=$w->infoAnchor();
	return unless defined($item);

	my ($lang, $cm) = $w->infoData($item);
	my $address = "";

	my $linkspackage = "SynSemClassHierarchy::" . uc($lang) . "::Links";
	my $data_cms = $self->data->lang_cms($lang);

	$address = $linkspackage->get_verb_info_link_address($self, $cm, $data_cms);
	$self->openurl($address) if ($address ne "");
	return;
}

sub modifyHierarchyConcept{
  my ($self, $hic_id) = @_;

  my $hic = $self->data->hierarchy->getHierarchyNodeByID($hic_id);

  my @value=();
  $value[0] = $hic_id;
  $value[1] = $self->data->hierarchy->getHierarchyConceptAttribute($hic, "name");

  $value[2] = $self->data->hierarchy->getHierarchyConceptDefinition($hic);

  my ($ok, @value) = $self->getHierarchyConcept("modify", @value);

  while ($ok){
	my $ret = $self->data->hierarchy->editHierarchyConcept($hic, @value);
	if ($ret == 1){
		$self->data->hierarchy->addHierarchyLocalHistory($parent_hic, "hierarchyConceptModify");
  		$self->get_editor_frame->update_title();
		return 1;
	}elsif ($ret==-2){
		SynSemClassHierarchy::Editor::warning_dialog($elf, "Can not change Hierarchy Concept name to " . $value[1] . ". This concept already exists!");
		($ok, @value) = $self->getHierarchyConcept("modify", @value);
		next;
	}elsif ($ret==-1){
		SynSemClassHierarchy::Editor::warning_dialog($elf, "Can not modify hierarchy concept - bad selected concept!");
		last;
	}
  }

}

sub addHierarchyConcept{
  my ($self, $parent_concept_id)=@_;
  my @value = ("", "", "");

  my $parent_hic = $self->data->hierarchy->getHierarchyNodeByID($parent_concept_id);
  my ($ok, @value)=$self->getHierarchyConcept("add", @value);

  while ($ok){
	my ($ret, $new_hic_node) = $self->data->hierarchy->addHierarchyConcept($parent_hic, @value);
	if ($ret == 1){
		$self->data->hierarchy->addHierarchyLocalHistory($parent_hic, "hierarchyConceptAdd");
  		$self->get_editor_frame->update_title();
		my $new_hic_id = $new_hic_node->getAttribute("id");
		return (1, $new_hic_id);
	}elsif ($ret==-2){
		SynSemClassHierarchy::Editor::warning_dialog($elf, "Can not add Hierarchy Concept with the name " . $value[1] . ". This concept already exists!");
		($ok, @value) = $self->getHierarchyConcept("add", @value);
		next;
	}elsif ($ret==-1){
		SynSemClassHierarchy::Editor::warning_dialog($elf, "Can not add new Hierarchy Concept - bad parent concept!");
		last;
	}
  }

  return (0, "");
}

sub getHierarchyConcept{
  my ($self,$action,@value)=@_;

  my ($ok, @new_value)=$self->show_hierarchy_concept_editor_dialog($action,@value);

  while ($ok){
	if ($new_value[1] eq ""){
  		SynSemClassHierarchy::Editor::warning_dialog($self,"Fill the Hierarchy Concept Name!");
		($ok, @new_value) = $self->show_hierarchy_concept_editor_dialog($action, @new_value);
		next;
	}elsif ($self->data->hierarchy->getHierarchyNodeByName($new_value[1])){
		my $n = $self->data->hierarchy->getHierarchyNodeByName($new_value[1]);
		my $n_id = $self->data->hierarchy->getHierarchyConceptAttribute($n, "id");
		if ($n_id ne $new_value[0]){
	  		SynSemClassHierarchy::Editor::warning_dialog($self,"Hierarchy Concept with name $new_value[1] already exists with the id $n_id. Fill another one!");
			($ok, @new_value) = $self->show_hierarchy_concept_editor_dialog($action, @new_value);
			next;
		}
	}
	last;
  }
  return ($ok,@new_value);
}

sub getHierarchyForClass{
  my ($self, $type, $focused, @values) = @_;  

  my ($ok, @new_values) = $self->show_choosing_hierarchy_concept_dialog($type, $focused, @values);

  while ($ok){
	if (($new_values[0] eq "") and ($new_values[1] eq "")){
		SynSemClassHierarchy::Editor::warning_dialog($self, "Select Hierarchy Concept!");
		($ok, @new_values) = $self->show_choosing_hierarchy_concept_dialog($type, "ID", @new_values);
	}
	last;
  }
  return ($ok, @new_values);
}

sub getNewParentForHierarchyConcept{
  my ($self, $focused, @values) = @_;

  my ($ok, @new_values) = $self->show_choosing_hierarchy_concept_dialog("Select parent" , $focused,  @values);

  while ($ok){
	if (($new_values[0] eq "") and ($new_values[1] eq "")){
		SynSemClassHierarchy::Editor::warning_dialog($self, "Select parent Hierarchy Concept!");
		($ok, @new_values) = $self->show_choosing_hierarchy_concept_dialog("Select parent", "ID", @new_values);
	}
	if ($self->data->hierarchy->isAncestor($values[0], $new_values[0])){
		SynSemClassHierarchy::Editor::warning_dialog($self, "New parent cannot be the descendant of the moving concept (or the same concept)!");
		($ok, @new_values) = $self->show_choosing_hierarchy_concept_dialog("Select parent", "ID", @new_values);
	}
	last;
  }
  return ($ok, @new_values);
}

sub show_hierarchy_concept_editor_dialog{
  my ($self, $action,@value)=@_;
  
  my $top=$self->widget()->toplevel;
  my $d;
  if ($action =~ /modify/){
    $d=$top->DialogBox(-title => "Modify hierarchy concept",
	  					 -cancel_button=>"Cancel",
					     -buttons => ["OK","Cancel"]);
  }else{
    $d=$top->DialogBox(-title => "Add hierarchy concept",
	  					 -cancel_button=>"Cancel",
						 -buttons => ["OK","Cancel"]);
  }

  $d->Subwidget("B_OK")->configure(-underline=>0);
  $d->Subwidget("B_Cancel")->configure(-underline=>0);
  $d->bind('<Return>',\&SynSemClassHierarchy::Widget::dlgReturn);
  $d->bind('<KP_Enter>',\&SynSemClassHierarchy::Widget::dlgReturn);
  $d->bind('<Alt-o>',\&SynSemClassHierarchy::Widget::dlgReturn);
  $d->bind('<Escape>',\&SynSemClassHierarchy::Widget::dlgCancel);
  $d->bind('<Alt-c>',\&SynSemClassHierarchy::Widget::dlgCancel);

  my $name_value = $value[1] || "";
  my $hic_name_l=$d->Label( -text => "Name")->grid(-row=>0,-column=>0, -sticky=>"w");
  my $hic_name=$d->Entry(qw/-width 30 -background white/, -text=>\$name_value)->grid(-row=>0, -column=>1, -sticky=>'w');
  $hic_name->focus;

  my $def_value = $value[2] || "";
  my $hic_definition_l=$d->Label( -text => "Definition")->grid(-row=>1,-column=>0, -sticky=>"w");
  my $hic_definition=$d->Entry(qw/-width 30 -background white/, -text=>\$def_value)->grid(-row=>1, -column=>1, -sticky=>'w');
  
  my $dialog_return = SynSemClassHierarchy::Widget::ShowDialog($d);
  if ($dialog_return =~ /OK/){
	  my @new_value;

	  $new_value[0] = $value[0];
	  $new_value[1]=$name_value;
	  $new_value[2]=$def_value;
   	  $d->destroy();
	  return (1, @new_value);
  }

  $d->destroy();
  return (0, undef);
}

sub show_choosing_hierarchy_concept_dialog{
 my ($self, $type, $focused, @values)=@_;

 my $top=$self->widget()->toplevel;
 my $d = $top->DialogBox(-title => ucfirst($type) . " hierarchy concept",
	 					 -cancel_button=>"Cancel",
	 					 -buttons => ["OK", "Cancel"]);

  $d->Subwidget("B_OK")->configure(-underline=>0);
  $d->Subwidget("B_Cancel")->configure(-underline=>0);
  $d->bind('<Return>',\&SynSemClassHierarchy::Widget::dlgReturn);
  $d->bind('<KP_Enter>',\&SynSemClassHierarchy::Widget::dlgReturn);
  $d->bind('<Alt-o>',\&SynSemClassHierarchy::Widget::dlgReturn);
  $d->bind('<Escape>',\&SynSemClassHierarchy::Widget::dlgCancel);
  $d->bind('<Alt-c>',\&SynSemClassHierarchy::Widget::dlgCancel);

  my $hic_id_value = $values[0];
  my $hic_name_value = $values[1];
  
  my $hic_id_l=$d->Label( -text => "Concept ID")->grid(-row=>0,-column=>0, -sticky=>"w");
  my $hic_id=$d->BrowseEntry(qw/-width 15 -disabledbackground white -disabledforeground black -state readonly /, -variable => \$hic_id_value )->grid(-row=>1, -column=>0, -sticky=>"e");
  my $hic_name_l_=$d->Label( -text => "Concept Name")->grid(-row=>0, -column=>1, -sticky=>"w");
  my $hic_name=$d->BrowseEntry(qw/-width 30 -disabledbackground white -disabledforeground black -state readonly/, -variable => \$hic_name_value)->grid(-row=>1, -column=>1, -sticky=>"e");

  $hic_id->configure(-browsecmd=>[ sub { my $hic = $self->data->hierarchy->getHierarchyNodeByID($hic_id_value); if ($hic->getAttribute("name") ne $hic_name_value) { $hic_name_value = $hic->getAttribute("name") }}] );
  $hic_name->configure(-browsecmd=>[ sub { my $hic = $self->data->hierarchy->getHierarchyNodeByName($hic_name_value); if ($hic->getAttribute("id") ne $hic_id_value) { $hic_id_value = $hic->getAttribute("id")} }] );

  my %hic_names =();
  foreach my $hic ($self->data->hierarchy->getSortedHierarchySubConcepts){

	my $hic_status = $self->data->hierarchy->getHierarchyConceptStatus($hic);
	$hic_status = "deleted" if ($hic->getAttribute("name") =~ /^deleted/);
	next if ($hic_status =~ /(moved|deleted)/);

	$hic_id->insert("end", $hic->getAttribute("id"));
	$hic_names{$hic->getAttribute("name")} = 1;
  }

  for my $hn (sort keys %hic_names){
	$hic_name->insert("end", $hn);
  }
  
  my $focused_entry=($focused eq "ID" ? $hic_id : $hic_name);
  my $dialog_return = SynSemClassHierarchy::Widget::ShowDialog($d, $focused_entry);
  if ($dialog_return =~ /OK/){
   my @new_values;
   $new_values[0]=$self->data->main->trim($hic_id_value);
   $new_values[1]=$self->data->main->trim($hic_name_value);
   $d->destroy();
   return (1, @new_values);
  }
  $d->destroy();
  return (0, undef);
}

sub show_note_editor_dialog{
  my ($self, $title, $text)=@_;

  my $editable = 0;
  $editable = 1 if ($title =~ /Edit/);
  my $top=$self->widget()->toplevel;
  my @buttons;
  my $ed_type;
  if ($editable){
  	@buttons = ["OK", "Cancel"];
	$ed_type = "Text";
  }else{
  	@buttons = ["Cancel"];
	$ed_type = "ROText";
  }
  my $d=$top->DialogBox(-title => $title,
	  					-cancel_button=>"Cancel",
						-default_button=>undef,
						-buttons => @buttons
					);


  if ($editable =~ /Edit/){
  	$d->Subwidget("B_OK")->configure(-underline=>0);
  	$d->bind('<Alt-o>',\&SynSemClassHierarchy::Widget::dlgReturn);
  }
  $d->Subwidget("B_Cancel")->configure(-underline=>0);
  $d->bind('<Return>','NoOp');
#  $d->bind('<KP_Enter>',\&SynSemClassHierarchy::Widget::dlgReturn);
  $d->bind('<Escape>',\&SynSemClassHierarchy::Widget::dlgCancel);
  $d->bind('<Alt-c>',\&SynSemClassHierarchy::Widget::dlgCancel);

  my $ed=$d->Scrolled($ed_type, qw/-width 150 -height 4 -background white -spacing3 5 -wrap word -scrollbars osoe/);
  $ed->pack(qw/-padx 5 -expand yes -fill both /);
  $ed->focus;
  $ed->delete('0.0','end');
  $ed->insert('0.0', $text);

  $ed->bind('<Control-a>', 'selectAll');
  $ed->bind('Tk::Text','<Control-p>',sub{ $ed->eventGenerate('<Control-y>'); Tk->break;});
  $ed->bind('Tk::Text','<Control-c>',sub{ $ed->eventGenerate('<Control-w>'); Tk->break;});

  if (SynSemClassHierarchy::Widget::ShowDialog($d,$ed) =~ /OK/) {
    my $newText=$ed->get('0.0', 'end');
    $d->destroy();
    return (1,$newText);
  }else{
    $d->destroy();
	return (0, undef);
  }

}

1;
