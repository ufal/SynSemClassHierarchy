# -*- mode: cperl; coding: utf-8; -*-
#
##############################################
# SynSemClassHierarchy::Data_hierarchy
##############################################

package SynSemClassHierarchy::Data_hierarchy;

use strict;
use utf8;


sub new {
  my ($self, $file, $novalidation)=@_;
  my $class = ref($self) || $self;
  my $new = bless [$class->parser_start($file,$novalidation),
		   $file, undef, undef, 0, []], $class;
  $new->loadListOfUsers();
  return $new;
}

sub parser {
  return undef unless ref($_[0]);
  return $_[0]->[0];
}

sub set_parser {
  return undef unless ref($_[0]);
  return $_[0]->[0]=$_[1];
}

sub doc {
  return undef unless ref($_[0]);
  return $_[0]->[1];
}

sub set_doc {
  return undef unless ref($_[0]);
  return $_[0]->[1]=$_[1];
}

sub file {
  return undef unless ref($_[0]);
  return $_[0]->[2];
}

sub set_file {
  return undef unless ref($_[0]);
  return $_[0]->[2]=$_[1];
}

sub user {
  my ($self)=@_;
  return undef unless ref($self);
  return $self->[3];
}

sub set_user{
  my ($self, $user)=@_;
  return undef unless ref($self);
  $self->[3]=$user;
}

sub loadListOfUsers {
  my ($self)=@_;
  my $users = {};
  return undef unless ref($self);
  my $doc=$self->doc();
  my ($head)=$doc->documentElement()->getChildElementsByTagName("header");
  if ($head) {
    my ($list)=$head->getChildElementsByTagName("list_of_users");
    if ($list) {
      foreach my $user ($list->getChildElementsByTagName("user")) {
	$users->{$user->getAttribute("id")} =
	  [
	   $user->getAttribute("name"),
	   $user->getAttribute("can_modify") eq "YES",
	  ]
      }
    }
  }
  $self->[4]=$users;
}

sub changed {
  my ($self)=@_;
  return undef unless ref($self);
  return $self->[5];
}

sub set_change_status {
  my ($self,$status)=@_;
  return undef unless ref($self);
  $self->[5]=$status;
}

sub clients {
  return $_[0]->[6];
}

sub dispose_node {
}

sub save {
}

sub doc_reload {
}

sub doc_free {
  my ($self)=@_;
  $self->make_clients_forget_data_pointers();
  $self->dispose_node($self->doc());
  $self->set_doc(undef);
}

sub reload {
  my ($self)=@_;
  $self->doc_free();
  $self->doc_reload();
  $self->loadListOfUsers();
  $self->set_change_status(0);
}

sub get_user_info {
  my ($self,$user)=@_;
  return exists($self->[4]->{$user}) ? $self->[4]->{$user} : ["unknown user",0];
}

sub user_can_modify {
  my ($self)=@_;
  return undef unless ref($self);
  return $self->get_user_info($self->user())->[1];
}

sub getUserName {
  my ($self)=@_;
  return undef unless ref($self);
  return $self->get_user_info($self->user())->[0];
}

sub compare {
  return $_[1] cmp $_[2];
}

sub getHierarchyNodeByID{
  my ($self, $id) = @_;

  my $doc=$self->doc();
  return unless $doc;
  my $docel=$doc->getDocumentElement();
  my ($body) = $docel->getChildElementsByTagName("body");

  my @nodes=$body->getDescendantElementsByTagName("hi_concept");
  foreach my $n (@nodes){
	return $n if ($n->getAttribute("id") eq $id);
  }
  return undef;
}

sub getHierarchyNodeByName{
  my ($self, $name, $id) = @_; # if ($id ne "") - excluding specified node

  my $doc=$self->doc();
  return unless $doc;
  my $docel=$doc->getDocumentElement();
  my ($body) = $docel->getChildElementsByTagName("body");

  my @nodes=$body->getDescendantElementsByTagName("hi_concept");
  foreach my $n (@nodes){
	next if (($id ne "") and ($n->getAttribute("id") eq $id)); 
	return $n if ($n->getAttribute("name") eq $name);
  }
  return undef;
}

sub getRootHierarchyNode{
  my ($self) = @_;
  	
  return $self->getHierarchyNodeByID("hic_0");
}

sub getHierarchyChildren{
  my ($self, $node) = @_;
  my ($childnode) = $node->getChildElementsByTagName("children");
  return () unless $childnode;

  return $childnode->getChildElementsByTagName("hi_concept");
}

sub getSortedHierarchySubConcepts{ #including parent concept
  my ($self, $node) = @_;
  unless ($node){
	$node = $self->getRootHierarchyNode;
  }
  my @nodes=($node);
  my @subconcepts = ();

   while (scalar @nodes > 0){
	my $node = shift @nodes;
	push @subconcepts, $node;
	unshift @nodes, $self->getHierarchyChildren($node);
  }

  return @subconcepts;
}

sub getHierarchyConceptNameByID{
  my ($self, $id) = @_;
  my $hierarchy_node = $self->getHierarchyNodeByID($id);
  return undef unless $hierarchy_node;

  return $hierarchy_node->getAttribute("name");
}

sub getHierarchyConceptStatus {
	my ($self, $hic_node) = @_;
	return undef unless $hic_node;

	my $status = $hic_node->getAttribute("status") || "active";
	return $status;
}

sub getHierarchyConceptAttribute {
  my ($self, $hic_node, $attrname) = @_;
  return undef unless $hic_node;

  return $hic_node->getAttribute($attrname);
}

sub setHierarchyConceptAttribute {
  my ($self, $hic_node, $attrname, $value) = @_;
  return undef unless $hic_node;

  $hic_node->setAttribute($attrname, $value);
  $self->set_change_status(1);
}

sub isAncestor{
  my ($self, $tested_id, $desc_id) = @_;
  return unless $tested_id;
  return unless $desc_id;

  my $n = $self->getHierarchyNodeByID($desc_id);

  while ($n){
	if ($n->nodeName() eq "hi_concept"){
	  return 1 if ($n->getAttribute("id") eq $tested_id);
	  last if ($n->getAttribute("id") eq "hic_0");
	}
  
	$n=$n->parentNode();
  }

  return 0;
}

sub getAncestorsIDs{
   my ($self, $node_id) = @_;
   return unless($node_id);
 
	my $n = $self->getHierarchyNodeByID($node_id);
 
	my @ancestorsIDs = ();
	while($n){
  	  if ($n->nodeName() eq "hi_concept"){
		last if ($n->getAttribute("id") eq "hic_0");
		push @ancestorsIDs, $n->getAttribute("id");
	  }
	  $n=$n->parentNode();
	}
	return @ancestorsIDs;
}

sub isParentHierarchyConcept{
	my ($self, $tested_id, $desc_id) = @_;
	return unless $tested_id;
	return unless $desc_id;

	my $n = $self->getHierarchyNodeByID($desc_id);
	return 0 if ($n->getAttribute("id") eq "hic_0");
	$n=$n->parentNode();
	while ($n){
		if ($n->nodeName() eq "hi_concept"){
		 	if ($n->getAttribute("id") eq $tested_id){
				return 1;
			}else{
				return 0;
			}
		}
		$n=$n->parentNode();
	}

}

sub getParentHierarchyConcept{
	my ($self, $hic_node) = @_;
	return unless $hic_node;
	return -1 if ($hic_node->getAttribute("id") eq "hic_0");
	
	my $n=$hic_node->parentNode();
	while($n){
		if ($n->nodeName() eq "hi_concept"){
			return $n;
		}
		$n=$n->parentNode();
	}

}

sub addHierarchyConcept {
  my ($self, $parent_node, @value) = @_; 	#value=("", name, definition)

  return -1 unless $parent_node;
  my $node_with_name = $self->getHierarchyNodeByName($value[1]);
  if ($node_with_name){  #node with $value[0] name already exists
	print "node with name $value[1] already exists - " . $node_with_name->getAttribute("name") . " (" . $node_with_name->getAttribute("id") . ")\n";
  	return -2;
  }
  my $newId = 1;
  foreach my $child ($self->getHierarchyChildren($parent_node)){
	my $child_id = $child->getAttribute("id");
	$child_id =~ s/^.*_//;
	$newId = $child_id + 1 if ($newId <= $child_id);
  }
  my $parent_id = $parent_node->getAttribute("id");
  if ($parent_id eq "hic_0"){
	$newId = "hic_" . $newId;
  }else{
	$newId = $parent_id . "_" . $newId;
  }

  my $doc = $self->doc();
  my ($children_node)= $parent_node->getChildElementsByTagName("children");
  unless ($children_node) {
	$children_node = $doc->createElement("children");
	$parent_node->appendChild($children_node);
  }

  my $new_node = $doc->createElement("hi_concept");
  $new_node->setAttribute("id", $newId);
  $new_node->setAttribute("status", "active");
  $children_node->appendChild($new_node);

  my $ret_val = $self->editHierarchyConcept($new_node, @value);
  if ($ret_val > 0){
	return (1,$new_node);
  }else{
	return ($ret_val, "");
  }

}

sub editHierarchyConcept{
  my ($self, $hic_node, @value) = @_;
 
  return -1 unless $hic_node;
  
  my $node_with_name = $self->getHierarchyNodeByName($value[1]);
  return -2 if ($node_with_name and $node_with_name ne $hic_node);  #node with $value[1] name already exists
  
  $hic_node->setAttribute("name", $value[1]);

  return $self->setHierarchyConceptDefinition($hic_node, $value[2]);
}

sub getHierarchyConceptDefinition{
  my ($self, $hic_node) = @_;
  return -1 unless ref($hic_node);

  my ($definition) = $hic_node->getChildElementsByTagName("definition");
  return "" unless $definition;

  my $text=$definition->getText();

  return $text;
}

sub setHierarchyConceptDefinition{
  my ($self, $hic_node, $text) = @_;
  return -1 unless ($hic_node);
  my ($olddef) = $hic_node->getChildElementsByTagName("definition");

  my $definition = $self->doc()->createElement("definition");
  if (not $olddef){
	return 1 if ($text eq "");
	$hic_node->appendChild($definition);
  }else{
	$olddef->replaceNode($definition);
  }
  $definition->appendText($text);
  $self->set_change_status(1);

  return 1;
}

sub markHierarchyConceptForCancel{
  my ($self, $hic_node) = @_;
  return unless $hic_node;
  my $name = $hic_node->getAttribute("name");
  $hic_node->setAttribute("name", "cancel - " . $name) if ($name !~ /^cancel - /);
  $hic_node->setAttribute("status", "canceled");
  $self->addHierarchyLocalHistory($hic_node, "markHierarchyConceptForCancel");
  $self->set_change_status(1);

  return 1;
}

sub setCanceledHierarchyConceptAsActive{
  my ($self, $hic_node) = @_;
  return unless $hic_node;
  my $new_name = $hic_node->getAttribute("name"); 
  $new_name =~ s/^cancel - //;

  if ($self->getHierarchyNodeByName($new_name, $hic_node->getAttribute("id"))){
	return -1;
  }

  $hic_node->setAttribute("name", $new_name);
  $hic_node->setAttribute("status", "active");
  $self->addHierarchyLocalHistory($hic_node, "setCanceledHierarchyConceptAsActive");
  $self->set_change_status(1);

  return 1;
}

sub setDeletedHierarchyConceptAsActive{
  my ($self, $hic_node) = @_;
  return unless $hic_node;
  my $new_name = $hic_node->getAttribute("name"); 
  $new_name =~ s/^deleted( - |_)//;

  if ($self->getHierarchyNodeByName($new_name, $hic_node->getAttribute("id"))){
	return -1;
  }
  my $parentNode=$self->getParentHierarchyConcept($hic_node);
  return -2 if ($parentNode and ($self->getHierarchyConceptStatus($parentNode) eq "deleted"));

  $hic_node->setAttribute("name", $new_name);
  $hic_node->setAttribute("status", "active");
  $self->addHierarchyLocalHistory($hic_node, "setDeletedHierarchyConceptAsActive");
  $self->set_change_status(1);


}

sub deleteHierarchySubtree{
  my ($self, $root_node) = @_;
  
  my @nodes = ($root_node);

  while (@nodes){
	my $node = shift @nodes;
	next if ($self->getHierarchyConceptStatus($node) =~ /(deleted|moved)/);
	return unless $self->deleteHierarchyConcept($node);
	foreach my $child ($self->getHierarchyChildren($node)){
		push @nodes, $child;
	}	
  }
  return 1;
}

sub deleteHierarchyConcept{
  my ($self, $hic_node) = @_;
  return unless $hic_node;
  return -1 if ($hic_node->getAttribute("id") eq "hic_0");

  my $name = $hic_node->getAttribute("name");
  $name =~ s/^cancel - //;
  $hic_node->setAttribute("name", "deleted - " . $name) if ($name !~ /^deleted/);
  $hic_node->setAttribute("status", "deleted");
  $self->addHierarchyLocalHistory($hic_node, "deleteHierarchyConcept");
  $self->set_change_status(1);
  return 1;
}

sub isValidHierarchyID{
  my ($self, $hic_id) = @_;
  if ($self->getHierarchyNodeByID($hic_id)){
	return 1;
  }
  return 0;
}

sub isValidHierarchyName{
  my ($self, $hic_name) = @_;
  if ($self->getHierarchyNodeByName($hic_name)){
	return 1;
  }
  return 0;
}

sub addHierarchyLocalHistory {
  my ($self,$hic,$type, $author)=@_;
  return unless $hic;
  my $doc=$self->doc();

  $author=$self->user() unless $author;
  my ($local_history)=$hic->getChildElementsByTagName("local_history");
  unless ($local_history) {
    $local_history=$doc->createElement("local_history");
    $hic->appendChild($local_history);
  }

  my $local_event=$doc->createElement("local_event");
  $local_history->appendChild($local_event);
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
  $local_event->setAttribute("time_stamp",sprintf('%d.%d.%d %02d:%02d:%02d',
                                          $mday,$mon+1,1900+$year,$hour,$min,$sec));
  $local_event->setAttribute("type_of_event",$type);
  $local_event->setAttribute("author",$author);
  $self->set_change_status(1);
  return $local_event;
}


sub register_client {
  my ($self,$client)=@_;
  my $clients=$self->clients();
  unless (grep {$_ == $client} @$clients) {
      push @$clients,$client;
  }
}

sub unregister_client {
  my ($self,$client)=@_;
  my $clients=$self->clients();
  @$clients=grep {$_ != $client} @$clients;
}

sub make_clients_forget_data_pointers {
  my ($self)=@_;
  my $clients=$self->clients();
  foreach my $client (@$clients) {
    $client->forget_data_pointers();
  }
}


sub DESTROY {
  my ($self)=@_;
  $self->set_parser(undef);
  $self->make_clients_forget_data_pointers();
}

1;
