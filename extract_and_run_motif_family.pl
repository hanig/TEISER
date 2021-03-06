#!/usr/bin/perl

my $teiserdir ;
BEGIN{
    if ((!$ENV{TEISERDIR}) || ($ENV{TEISERDIR} eq '')) {
	$teiserdir="./" ;
	print "The TEISERDIR environment variable is not set. It is set to default.\n";
    }
    else{
	print "The TEISERDIR environment variable is ".$ENV{TEISERDIR}."\n" ;
	$teiserdir = $ENV{TEISERDIR};
    }
}

my $cmdline = "perl teiser.pl";
foreach my $r (@ARGV) {
  $cmdline .= " $r";
}

my $programdir = $teiserdir."/Programs" ;
my $scriptdir  = $teiserdir."/Scripts" ;
my $pwd        = `pwd`; $pwd =~ s/\n//;
use lib "$teiserdir/Scripts";

use PBS ;
use strict;
use Sets;
use Table;
use Getopt::Long;
use Data::Dumper;

if (@ARGV == 0) {
  die "Usage: perl teiser.pl --expfile=FILE --exptype=TXT --species=SP\n";
}

my @argv_copy = @ARGV;

my $expfile          = undef ;
my $motiffile        = undef ;
my $listfile         = undef ;
my $homologyfile     = undef ;
my $fastafile_rna    = undef ;
my $species          = undef ;
my $exptype          = "discrete" ;
my $ebins            = undef ; 
my $quantized        = 1 ;
my $divbins          = 50.0 ;
my $mbins            = 2 ;
my $type             = "DN" ;

my $shuffle_mifind   = 1500000 ;
my $maxp_mifind      = 0.00000001 ;
my $shuffle_mimotif  = 1000000 ;
my $maxp_mimotif     = 0.0000001 ;
my $shuffle_page     = 10000 ;
my $maxp_page        = 0.005 ;
my $maxz_mioptimize  = -1 ;
my $maxz_mifind      = -1 ;
my $jn_t             = 8 ;
my $min_r            = 2.0 ;
my $dG_t             = -1.0 ;

my $clusters         = 5 ;
my $draw_min         = -10 ;
my $draw_max         = 10 ;
my $removecols_draw  = undef ;
my $colmap_matrix    = "$scriptdir/HEATMAPS/cmap_1.txt" ;
my $colmap_mimatrix  = "$scriptdir/HEATMAPS/cmap_2.txt" ;
my $colmap_page      = "$scriptdir/HEATMAPS/cmap_3.txt" ;
my $order            = 0 ;

my $dodrawmatrix       = 1 ;
my $dodrawmimatrix     = 1 ;
my $dodrawpagematrix   = 1 ;
my $dodrawmotifs       = 1 ;
my $doskipdiscovery    = 0 ;
my $domifind           = 1 ;
my $doskipoptimization = 0 ;
my $domioptimize       = 1 ;
my $doonlypositive     = 0 ;
my $domireport         = 1 ;
my $doremovedups       = 1 ;
my $doremoveextras     = 1 ;
my $dopagerun          = 1 ;
my $domotifind         = 1 ;
my $doconservation     = 1 ;

my $suffix           = "" ;
my $submit           = 0 ;
my $platform         = undef ;
my $walltime         = "72:00:00" ;
my $queue            = undef ;
my $jobid            = undef ;

GetOptions ('expfile=s'              => \$expfile,
	    'motiffile=s'             => \$motiffile,
      'fastafile_rna=s'          => \$fastafile_rna,
	    'species=s'              => \$species,
	    'exptype=s'              => \$exptype,
	    'ebins=i'                => \$ebins,
	    'quatized=i'             => \$quantized,
	    'divbins=i'              => \$divbins,
	    'mbins=i'                => \$mbins,
	    'type=s'                 => \$type,

	    'shuffle_mifind=i'       => \$shuffle_mifind,
	    'maxp_mifind=f'          => \$maxp_mifind,
	    'shuffle_mimotif=i'      => \$shuffle_mimotif,
	    'maxp_mimotif=f'         => \$maxp_mimotif,
	    'shuffle_page=i'         => \$shuffle_page,
	    'maxp_page=f'            => \$maxp_page,
	    'maxz_mioptimize=f'      => \$maxz_mioptimize,
	    'maxz_mifind=f'          => \$maxz_mifind,
	    'jn_t=i'                 => \$jn_t,
      'min_r=f'                => \$min_r,
      'dG_t=f'                 => \$dG_t,

	    'cluaters=i'             => \$clusters,
	    'order=i'                => \$order,
	    'draw_min=f'             => \$draw_min,
	    'draw_max=f'             => \$draw_max,
	    'removecols_draw=i'      => \$removecols_draw,

	    'dodrawmatrix=i'         => \$dodrawmatrix,
	    'dodrawmimatrix=i'       => \$dodrawmimatrix,
	    'dodrawpagematrix=i'     => \$dodrawpagematrix,
	    'dodrawmotifs=i'         => \$dodrawmotifs,
	    'doskipdiscovery=i'      => \$doskipdiscovery,
	    'doskipoptimization=i'      => \$doskipoptimization,
	    'domifind=i'             => \$domifind,
	    'domioptimize=i'         => \$domioptimize,
	    'doonlypositive=i'       => \$doonlypositive,
	    'domireport=i'           => \$domireport,
	    'doremovedups=i'         => \$doremovedups,
      'doremoveextras=i'      => \$doremoveextras,
	    'dopagerun=i'            => \$dopagerun,
	    'domotifind=i'           => \$domotifind,
	    'doconservation=i'       => \$doconservation,

	    'suffix=s'               => \$suffix,
	    'submit=i'               => \$submit,
	    'platform=s'             => \$platform,
	    'walltime=s'             => \$walltime,) ;

if (!defined($expfile)) {
    die("Please input an expression file (--expfile=FILE).\n");
}

if ($doskipdiscovery == 1) {
    $domifind       = 0;
    $domioptimize   = 0;
}

if ($doskipoptimization == 1) {    
    $domioptimize   = 0;
}

if ($exptype eq "discrete") {
  $quantized = 1 ;
} elsif ($exptype eq "continuous"){
  $quantized = 0 ;
}

if (($quantized == 0) && (!defined($removecols_draw))) {
    $removecols_draw = 0;
}
  
if (defined($species)) {
  #  read species file
    my $species_data = readSpeciesData($species);
  
    $fastafile_rna    = $species_data->{"fastafile_rna"} if (!defined($fastafile_rna)) ;
    $homologyfile     = $species_data->{"homologyfile"} if (!defined($homologyfile)) ;
    $listfile         = $species_data->{"genelistfile"} if  (!defined($listfile));
}

my $time = Sets::getNiceDateTime(1) ;
my $a_ref_files = Sets::getFiles($expfile);

foreach my $expfile (@$a_ref_files) {
  if (&check_input_file($expfile, $exptype) == 0) {
    die "Please correct input expression file.\n";
  }

  my $expfile_file = Sets::filename($expfile);

  my $target_dir = "$expfile"."_FAMILY"."/$suffix";
  if ($suffix eq ""){
    $target_dir = "$expfile"."_FAMILY";
  }
  if (! -e "$expfile"."_FAMILY") {
    mkdir "$expfile"."_FAMILY" ; 
  }
  if (! -e $target_dir) {
    mkdir $target_dir; 
  }

  open OUTC, ">$target_dir/cmdline.txt"
    or print "Cannot open $target_dir/cmdline.txt";
  print OUTC "$cmdline\n";
  close OUTC;

  ######## remove duplicates ########
  my $expfile_nodups     = "$target_dir/$expfile_file" ;
  my $expfile_pre        = "$target_dir/$expfile_file.pre" ;


  my $pbs = PBS->new;
  $pbs->setPlatform($platform) if (defined($platform));
  $pbs->setQueue($queue)       if (defined($queue));
    
  $pbs->setWallTime($walltime);
  $pbs->addCmd("export TEISERDIR=$teiserdir");
  $pbs->addCmd("cd $pwd");
    
  $pbs->setScriptName("$target_dir/$expfile_file.script");
  $pbs->addCmd("date");
  if  ($doremoveextras == 1) {
    $pbs->addCmd("echo \"Remove genes without sequence info, create $target_dir/$expfile_pre\"");
    $pbs->addCmd("perl $scriptdir/remove_genes_without_sequence.pl --expfile=$expfile --listfile=$listfile --outfile=$expfile_pre");
  }else{
    system("cp $expfile $expfile_pre") ;
  }

  $pbs->addCmd("echo \"Remove duplicates, create $target_dir/$expfile_file\"");
    
  if  ($doremovedups == 1) {
    my %PARAMS = ("expfile"       => $expfile_pre,
		  "quantized"     => $quantized, 
		  "fastafile"     => $fastafile_rna,
		  "dupfile"       => undef,
		  "ebins"         => $ebins,
		  "divbins"       => $divbins,    
		  "outfile"       => $expfile_nodups) ;
	
    my $cmd = &get_cmd_removedups(\%PARAMS) ;
    $pbs->addCmd($cmd) ;
  }else{
    system("cp $expfile_pre $expfile_nodups") ;
  }

  ######## quatize expression profile ########
  my $expfile_quant      = "$target_dir/$expfile_file.q" ;

  if ($quantized == 0) {
    $pbs->addCmd("echo \"Quantizing the input file.\"");    
    my $cmd = "perl $scriptdir/quantize_input_vector.pl --expfile=$expfile_nodups --outfile=$expfile_quant";
    if (defined($ebins)) {
      $cmd .= " -ebins $ebins ";
    }
    if (defined($divbins)) {
      $cmd .= " -divbins $divbins ";
    }
    $pbs->addCmd($cmd);
  }

  ######## mi report for motif family ########
  my $matrixfile       = "$target_dir/$expfile_file.fmatrix" ;
  my $summaryfile      = "$target_dir/$expfile_file.fsummary" ;
  my $reportfile       = "$target_dir/$expfile_file.freport" ;
  my $profile          = "$target_dir/$expfile_file.fprofile" ;

  $pbs->addCmd("echo \"step 2: mi report for motif family.\""); 
  my %PARAMS = ("expfile"         => $expfile_nodups,
    "quantized"       => $quantized,
    "shuffle"         => $shuffle_mifind,
    "rna_fastafile"   => $fastafile_rna,
    "motiffile"       => $motiffile,
    "ebins"           => $ebins,
    "divbins"         => $divbins,
    "minr"            => $min_r,
    "matrixfile"      => $matrixfile,
    "summaryfile"     => $summaryfile,
    "reportfile"      => $reportfile,
    "profile"         => $profile,
    "max_p"           => $maxp_mifind,
    "max_z"           => $maxz_mioptimize) ;
  my $cmd = &get_cmd_mi_report_motif_family(\%PARAMS);
  $pbs->addCmd($cmd);

  ######## RNA fold ########
  my $cmd = "perl -pi -e 's/\\t/_/g' $reportfile";
  $pbs->addCmd($cmd);
  $pbs->addCmd("echo \"step 3: Running Vienna RNAfold.\""); 
  $pbs->addCmd($cmd);
  my $cmd = "/Users/hani/Life/Projects/Applications/ViennaRNA-2.1.2/Progs/RNAfold -p0 --noPS < $reportfile > $reportfile.vienna";
  $pbs->addCmd($cmd);
  my $cmd = "perl $scriptdir/decode_vienna_by_motif_match.pl $reportfile.vienna > $reportfile.vienna.parsed" ;
  $pbs->addCmd($cmd);
  my $cmd = "cut -f 5 $reportfile.vienna.parsed > $reportfile.vienna.parsed.dG" ;
  $pbs->addCmd($cmd);
  my $cmd = "AVE=\$(cat $reportfile.vienna.parsed.dG ".'| perl -e \'use List::Util qw(max min sum); @a=();while(<>){$sqsum+=$_*$_; push(@a,$_)}; $n=@a;$s=sum(@a);$a=$s/@a;$m=max(@a);$mm=min(@a);$std=sqrt($sqsum/$n-($s/$n)*($s/$n));$mid=int @a/2;@srtd=sort @a;if(@a%2){$med=$srtd[$mid];}else{$med=($srtd[$mid-1]+$srtd[$mid])/2;};print $a;\')' ;
  $pbs->addCmd($cmd);
  my $cmd = "SD=\$(cat $reportfile.vienna.parsed.dG ".'| perl -e \'use List::Util qw(max min sum); @a=();while(<>){$sqsum+=$_*$_; push(@a,$_)}; $n=@a;$s=sum(@a);$a=$s/@a;$m=max(@a);$mm=min(@a);$std=sqrt($sqsum/$n-($s/$n)*($s/$n));$mid=int @a/2;@srtd=sort @a;if(@a%2){$med=$srtd[$mid];}else{$med=($srtd[$mid-1]+$srtd[$mid])/2;};print $std;\')' ;
  $pbs->addCmd($cmd);
  my $cmd = 'THRESH=$(echo "$AVE - $SD" | bc)' ;
  $pbs->addCmd($cmd);
  my $cmd = 'awk -v t=$THRESH \'{if ($5<t) print}\''." $reportfile.vienna.parsed > $reportfile.vienna.parsed.selected" ;
  $pbs->addCmd($cmd);
  my $cmd = "cut -f 2 $reportfile.vienna.parsed.selected | sort -u > $reportfile.vienna.parsed.selected.list" ;
  $pbs->addCmd($cmd);

  ######## mi report for gene list ########
  my $genefile         = "$reportfile.vienna.parsed.selected.list" ;
  my $matrixfile       = "$target_dir/$expfile_file.matrix" ;
  my $summaryfile      = "$target_dir/$expfile_file.summary" ;
  my $reportfile       = "$target_dir/$expfile_file.report" ;
  my $profile          = "$target_dir/$expfile_file.profile" ;

  $pbs->addCmd("echo \"step 4: mi report for gene list.\""); 
  my %PARAMS = ("expfile"         => $expfile_nodups,
		"quantized"       => $quantized,
		"shuffle"         => $shuffle_mifind,
		"genefile"        => $genefile,
		"ebins"           => $ebins,
		"divbins"         => $divbins,
    "minr"            => $min_r,
		"matrixfile"      => $matrixfile,
    "summaryfile"     => $summaryfile,
    "reportfile"      => $reportfile,
    "profile"         => $profile,
		"max_p"           => $maxp_mifind,
		"max_z"           => $maxz_mioptimize) ;

  my $cmd = &get_cmd_mi_report_gene_list(\%PARAMS);
  $pbs->addCmd($cmd);

    ######## drawing matrix ########
  if ($dodrawmatrix == 1){
    $pbs->addCmd("echo \"step 7: drawing matrix.\"");
     my %PARAMS = ("pvmatrixfile"  => $matrixfile,
		  "summaryfile"     => $summaryfile,
		  "expfile"         => $expfile_nodups,
		  "quantized"       => $quantized,
		  "colmap"          => $colmap_matrix,
		  "order"           => $order,
		  "min"             => $draw_min,
		  "max"             => $draw_max,
		  "cluster"         => $clusters,
      "suffix"         =>  "",) ;
    
    my $cmd = &get_cmd_drawmatrix(\%PARAMS);
    $pbs->addCmd($cmd);
  }  
  if ($submit == 0) {
    $pbs->execute;
  }else{
    $jobid = $pbs->submit; print "Submitted job $jobid.\n";
  }
}





sub readSpeciesData {
  my ($species) = @_;
  
  my %H = ();
  open IN, "$ENV{TEISERDIR}/TEISER_Data/species_data/$species" or die "No data file for $species.\n";
  while (my $l = <IN>) {
    chomp $l;
    my @a = split /\t/, $l, -1;    
    if ($a[1] =~ /^TEISER_Data/) {
      $a[1] = "$ENV{TEISERDIR}/$a[1]";
    }
    $H{$a[0]} = $a[1];
  }  
  close IN;
  
  return \%H;
}

sub check_input_file {
  my ($expfile, $exptype) = @_;
  
  my $ta = Table->new;
  $ta->loadFile($expfile);
  my $a_ref = $ta->getArray();
  
  my $r = shift @$a_ref; 
  if ($r->[1] =~ /^\d/) {
    print "WARNING: your file might not contain a header line ($r->[1]).\n";
  }

  if (scalar(@$a_ref)<2){
    print "ERROR: your expfile is not valid. Most probably it contains '\r' instead of '\n'\n" ;
    return 1 ;
  }
  
  my %H = ();
  my %V = ();
  foreach my $r (@$a_ref) {
    if (defined($H{$r->[0]})) {
      print "Your files contains multiple rows with the same gene id. Please correct that before applying TEISER.\n";
      return 0;
    }
    $H{$r->[0]} ++;
    $V{$r->[1]} = 1;
  } 
  
  
  my @v = values ( %V );
  @v = sort { $a <=> $b } @v;
  my $max = $#v;
  if (($exptype eq 'discrete') && (scalar(@v) != $max+1)) {
    my $n1 = scalar(@v);
    my $n2 = $max + 1;
    die "Problem. Your discrete vector is missing some symbols ($n1 != $n2).\n";
    return 0;
  }
  
  return 1;
}

sub get_cmd_removedups {
  my ($p) = @_;
  my $todo = "perl $scriptdir/remove_duplicates.pl --expfile=$p->{expfile} --quantized=$p->{quantized} --fastafile=$p->{fastafile} --outfile=$p->{outfile}";
  if (defined($p->{dupfile})) {
    $todo .= " --dupfile=$p->{dupfile} ";
  }
  if (defined($p->{ebins})) {
    $todo .= " --ebins=$p->{ebins} ";
  }
  if (defined($p->{divbins})) {
    $todo .= " --divbins=$p->{divbins} ";
  }
  return $todo;
}

sub get_cmd_mi_report_motif_family {
  my ($p) = @_;
  my $todo = "$programdir/mi_report_motif_family -expfile $p->{expfile} -motiffile $p->{motiffile} -rna_fastafile $p->{rna_fastafile} -reportfile $p->{reportfile} -matrixfile $p->{matrixfile} -summaryfile $p->{summaryfile} -profile $p->{profile} -quantized $p->{quantized} -shuffle $p->{shuffle}" ;
  if (defined($p->{ebins})) {
    $todo .= " -ebins $p->{ebins} ";
  }
  if (defined($p->{divbins})) {
    $todo .= " -divbins $p->{divbins} ";
  }
  return $todo;
}

sub get_cmd_mi_report_gene_list {
  my ($p) = @_;
  my $todo = "$programdir/mi_report_gene_list -expfile $p->{expfile} -genefile $p->{genefile} -quantized $p->{quantized} -shuffle $p->{shuffle} -matrixfile $p->{matrixfile} -summaryfile $p->{summaryfile} -profile $p->{profile}" ;
  if (defined($p->{ebins})) {
    $todo .= " -ebins $p->{ebins} ";
  }
  if (defined($p->{jn_t})) {
      $todo .= " -jn_t $p->{jn_t} ";
  }
  if (defined($p->{divbins})) {
    $todo .= " -divbins $p->{divbins} ";
  }
  return $todo;
}

sub get_cmd_drawmatrix {
  my ($p) = @_;
  my $todo = "perl $scriptdir/teiser_draw_matrix.pl --pvmatrixfile=$p->{pvmatrixfile} --summaryfile=$p->{summaryfile} --expfile=$p->{expfile} --quantized=$p->{quantized} --colmap=$p->{colmap} --order=$p->{order} --min=$p->{min} --max=$p->{max} --cluster=$p->{cluster} --suffix=$p->{suffix}" ;
  return $todo;
}

