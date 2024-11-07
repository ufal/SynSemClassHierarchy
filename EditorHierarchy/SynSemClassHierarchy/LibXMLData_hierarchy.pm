##############################################
# SynSemClassHierarchy::LibXMLData_hierarchy
##############################################

package SynSemClassHierarchy::LibXMLData_hierarchy;
use strict;
use base qw(SynSemClassHierarchy::Data_hierarchy);
use XML::LibXML;
use XML::LibXML::Iterator;

sub parser_start {
  my ($self, $file, $novalidation)=@_;
  my $parser;
  $parser=XML::LibXML->new();
  return () unless $parser;
  if (!$novalidation) {
    $parser->validation(1);
    $parser->load_ext_dtd(1);
    $parser->expand_entities(1);
  } else {
    $parser->validation(0);
    $parser->load_ext_dtd(0);
    $parser->expand_entities(0);
  }
  my $doc;
  print STDERR "parsing file $file\n";
  eval {
      $doc=$parser->parse_file($file);
  };
  print STDERR "$@\ndone\n";
  die "$@\n" if $@;
  $doc->indexElements() if ref($doc) and $doc->can('indexElements');
  return ($parser,$doc);
}

sub doc_reload {
  my ($self)=@_;
  my $parser=$self->parser();
  return unless $parser;
  $parser->load_ext_dtd(1);
  $parser->validation(0);
  print STDERR "parsing file ",$self->file,"\n";
  eval {
    my $doc=$parser->parse_file($self->file);
    $self->set_doc($doc);

  };
  print STDERR "$@\ndone\n";
}

sub save {
  my ($self, $no_backup,$indent)=@_;
  my $file=$self->file();
  return unless ref($self);
  my $backup=$file;
  if ($^O eq "MSWin32") {
    $backup=~s/(\.xml)?$/.bak/i;
  } else {
    $backup.="~";
  }

  unless ($no_backup || rename $file, $backup) {
    warn "Couldn't create backup file, aborting save!\n";
    return 0;
  }
  if ($self->doc()->can('toFile')) {
    $self->doc()->toFile($file,$indent);
    $self->set_change_status(0);
    return 1;
  }
  my $output;
  if ($file=~/.gz$/) {
    eval {
      $output = new IO::Pipe();
      $output && $output->writer("$ZBackend::gzip > \"$file\"");
    };
  } else {
    $output = new IO::File(">$file");
  }
  unless ($output) {
    print STDERR "ERROR: cannot write to file $file\n";
    return 0;
  }
  $output->print($self->doc()->toString($indent));
  $output->close();
  $self->set_change_status(0);
  print STDERR "File $file saved\n";
  return 1;
}

sub isEqual {
  my ($self,$a,$b)=@_;
  return unless ref($a);
  return $a->isSameNode($b);
}




1;
