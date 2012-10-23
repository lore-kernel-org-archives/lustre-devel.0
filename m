From: Nathan Rutman <nathan_rutman@xyratex.com>
Date: Tue, 23 Oct 2012 11:36:02 -0700
Subject: [Lustre-devel] Language choice for Lustre tests
Message-ID: <9E235E88-FAD1-44BF-A4DC-12A5801E0467@xyratex.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

At LAD'12 we proposed a plan for improving the Lustre test framework as an important part of the Lustre quality story.  One of the discussion points there was that the bash language of the current tests was lacking in a variety of areas.  We're moving forward with this work but need community agreement on the best course.  

Given the requirements and language options below, the reasonable choices rapidly diminish to a showdown between perl and python.  I think we're leaning at this point toward perl, based on it's superior speed and inter-version compatibility.  The final piece of the puzzle is the knowledge of existing Lustre test writers, so please chime in.  (But note that "popularity" is the reason we chose bash the first time, and look where that got us...)

	requirements
		1. easy to use
		2. strict structure
		3. universally available
		4. widely maintained
		5. widely understood
		6. good filesystem interface: posix API
		7. fast - replace e.g. createmany with embedded function
		8. operate remote instances
		9. inter-version compatibility
	options
		bash - capable, but too flexible, easy to abuse
		perl - forward compatible, universal, more widely understood, xperior, compact; hard to read later
			posix::open, opendir, lseek, etc.
	parallel::MPI
			~2x faster than python
			more version compatible
		python - very clear structure, swig module for c inclusion; non-standard installations, support
			os.open: all c flags	
			MPI bindings
			tab/space requirements make remote editing more difficult
		cucumber - ruby based, difficult deployment
		java - easy deployment, dev environ, debugger, fast; must compile
		ruby - compact


http://silicainsilico.wordpress.com/2012/03/26/switching-from-perl-to-python-speed/
http://tenser.typepad.com/tenser_said_the_tensor/2006/08/python_vs_perl_.html
http://opennomad.com/content/performance-different-scripting-languages-shell-v-perl-v-python-v-ruby
http://hentenaar.com/serendipity/index.php?/archives/27-Benchmark-PHP-vs.-Python-vs.-Perl-vs.-Ruby.html


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20121023/3ba94dff/attachment.htm>
