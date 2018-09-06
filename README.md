Replicable Homebrew `make` Failure
==================================

1.  Install the tap and install `makefail`:

    ``` sh
    brew tap theory/makefail
    brew install --keep-tmp makefail
    ```

    Sample output:

    ```
    ==> Installing makefail from theory/makefail
    ==> Downloading https://raw.githubusercontent.com/theory/homebrew-makefail/master/tryme.tgz
    Already downloaded: /Users/david/Library/Caches/Homebrew/downloads/36509c8de1f57856d162c29aa3219c6c50900bc352d5485bbb150fab404d727d--tryme.tgz
    ==> cpanm --quiet --notest --local-lib-contained tryit List::MoreUtils::XS Exporter::Tiny
    ==> cpanm --verbose --notest --local-lib-contained tryit --installdeps .
    Last 15 lines from /Users/david/Library/Logs/Homebrew/makefail/02.cpanm:
    Checking if you have List::MoreUtils::XS 0.426 ... Yes (0.428)
    Checking if you have ExtUtils::MakeMaker 0 ... Yes (6.66)
    Checking if you have Exporter::Tiny 0.038 ... Yes (1.002001)
    OK
    Building List-MoreUtils-0.428 ... cp lib/List/MoreUtils/Contributing.pod blib/lib/List/MoreUtils/Contributing.pod
    cp lib/List/MoreUtils.pm blib/lib/List/MoreUtils.pm
    cp lib/List/MoreUtils/PP.pm blib/lib/List/MoreUtils/PP.pm
    Appending installation info to /private/tmp/makefail-20180906-25247-4rfpkj/tryme/tryit/lib/perl5/darwin-thread-multi-2level/perllocal.pod
    OK
    Successfully installed List-MoreUtils-0.428
    Installing /private/tmp/makefail-20180906-25247-4rfpkj/tryme/tryit/lib/perl5/darwin-thread-multi-2level/.meta/List-MoreUtils-0.428/MYMETA.json
    Installing /private/tmp/makefail-20180906-25247-4rfpkj/tryme/tryit/lib/perl5/darwin-thread-multi-2level/.meta/List-MoreUtils-0.428/install.json
    ! Installing the dependencies failed: Module 'List::MoreUtils' is not installed
    ! Bailing out the installation for ..
    1 distribution installed
    ==> Kept temporary files
    Temporary files retained at /private/tmp/makefail-20180906-25247-4rfpkj

    If reporting this issue please do so at (not Homebrew/brew or Homebrew/core):
    https://github.com/theory/homebrew-makefail/issues
    ```

2.  Note that cpanminus reports that List::MoreUtils was "successfully
    installed", but then later says that it was not. Examine the full log output
    in `~/Library/Logs/Homebrew/makefail/02.cpanm` ([sample](eg/fail.log)).

3.  Switch to the temp directory into which files have been installed, indicated
    by the log line that begins with "Entering". In the [sample](eg/fail.log),
    its `/private/tmp/makefail-20180906-25247-4rfpkj/tryme`. Note  that
    `MoreUtils.pm` has not been copied into the `tryit` directory.

    ```
    $ find tryit -type f
    tryit/lib/perl5/darwin-thread-multi-2level/.meta/List-MoreUtils-XS-0.428/MYMETA.json
    tryit/lib/perl5/darwin-thread-multi-2level/.meta/List-MoreUtils-XS-0.428/install.json
    tryit/lib/perl5/darwin-thread-multi-2level/.meta/XSLoader-0.24/MYMETA.json
    tryit/lib/perl5/darwin-thread-multi-2level/.meta/XSLoader-0.24/install.json
    tryit/lib/perl5/darwin-thread-multi-2level/.meta/Exporter-Tiny-1.002001/MYMETA.json
    tryit/lib/perl5/darwin-thread-multi-2level/.meta/Exporter-Tiny-1.002001/install.json
    tryit/lib/perl5/darwin-thread-multi-2level/.meta/List-MoreUtils-0.428/MYMETA.json
    tryit/lib/perl5/darwin-thread-multi-2level/.meta/List-MoreUtils-0.428/install.json
    tryit/lib/perl5/darwin-thread-multi-2level/auto/List/MoreUtils/XS/XS.bundle
    tryit/lib/perl5/darwin-thread-multi-2level/auto/List/MoreUtils/XS/XS.bs
    tryit/lib/perl5/darwin-thread-multi-2level/auto/List/MoreUtils/XS/.packlist
    tryit/lib/perl5/darwin-thread-multi-2level/auto/Exporter/Tiny/.packlist
    tryit/lib/perl5/darwin-thread-multi-2level/auto/XSLoader/.packlist
    tryit/lib/perl5/darwin-thread-multi-2level/List/MoreUtils/XS.pm
    tryit/lib/perl5/darwin-thread-multi-2level/perllocal.pod
    tryit/lib/perl5/darwin-thread-multi-2level/XSLoader.pm
    tryit/lib/perl5/Exporter/Tiny.pm
    tryit/lib/perl5/Exporter/Tiny/Manual/Exporting.pod
    tryit/lib/perl5/Exporter/Tiny/Manual/QuickStart.pod
    tryit/lib/perl5/Exporter/Tiny/Manual/Etc.pod
    tryit/lib/perl5/Exporter/Tiny/Manual/Importing.pod
    tryit/lib/perl5/Exporter/Shiny.pm
    ```

4.  Switch to the work directory reported in `02.cpanm` and then into the
    `List-MoreUtils-0.428` directory and examine `List-MoreUtils-0.428/Makefile`
    ([sample](eg/Makefile)). Note that there are two `pure_site_install`
    targets, both specified with a double colon, so `make` should know to run
    them both. They look like this:

    ``` make
    pure_site_install ::
    	$(NOECHO) $(RM_F) '$(DESTINSTALLSITEARCH)/List/MoreUtils.pm'
    ```

    And:

    ```
    pure_site_install :: all
    	$(NOECHO) $(MOD_INSTALL) \
    		read $(SITEARCHEXP)/auto/$(FULLEXT)/.packlist \
    		write $(DESTINSTALLSITEARCH)/auto/$(FULLEXT)/.packlist \
    		$(INST_LIB) $(DESTINSTALLSITELIB) \
    		$(INST_ARCHLIB) $(DESTINSTALLSITEARCH) \
    		$(INST_BIN) $(DESTINSTALLSITEBIN) \
    		$(INST_SCRIPT) $(DESTINSTALLSITESCRIPT) \
    		$(INST_MAN1DIR) $(DESTINSTALLSITEMAN1DIR) \
    		$(INST_MAN3DIR) $(DESTINSTALLSITEMAN3DIR)
    	$(NOECHO) $(WARN_IF_OLD_PACKLIST) \
    		$(PERL_ARCHLIB)/auto/$(FULLEXT)
    ```

    The second one is the one that should install the `MoreUtils.pm`. It does
    not appear to have been executed.

5.  Run `make install` manually:

    ```
    /usr/local/Homebrew/Library/Homebrew/shims/mac/super/make install
    Installing /private/tmp/makefail-20180906-25247-4rfpkj/tryme/tryit/lib/perl5/List/MoreUtils.pm
    Installing /private/tmp/makefail-20180906-25247-4rfpkj/tryme/tryit/lib/perl5/List/MoreUtils/PP.pm
    Installing /private/tmp/makefail-20180906-25247-4rfpkj/tryme/tryit/lib/perl5/List/MoreUtils/Contributing.pod
    Appending installation info to /private/tmp/makefail-20180906-25247-4rfpkj/tryme/tryit/lib/perl5/darwin-thread-multi-2level/perllocal.pod
    ```

6.  Note that `MoreUtils.pm` has not been installed. Questions:

    *   Why didn't it get installed by the execution of the formula?
    *   Is there something in the environment that changes the behavior of `make`?
    *   Is it the case that `make` only runs one `pure_site_install` target when run by the formula?

7.  Try again, but turn on debugging output for `make install`:

    ```
    brew install --keep-tmp --with-install-debug makefail
    ```

    The build appears to succeed, but only because of the way `cpanminus` has
    been executed. `MoreUtils.pm` still will not have been installed. See
    `~/Library/Logs/Homebrew/makefail/02.cpanm` for the complete debug output
    [sample](eg/debug.log).



