From: Kilian Cavalotti <kilian.cavalotti.work@gmail.com>
Date: Fri, 26 Oct 2012 13:53:26 +0200
Subject: [Lustre-devel] Language choice for Lustre tests
In-Reply-To: <508A4F5A.8000207@xyratex.com>
References: <EA3A770421F31B4BB895DD3AB9224495706F0E@fmsmsx119.amr.corp.intel.com>
	<BF3E1573-A1E3-47DF-B1B1-866EB65A0D49@xyratex.com>
	<EA3A770421F31B4BB895DD3AB9224495709D89@fmsmsx119.amr.corp.intel.com>
	<3E3EE9AC-9DD4-4DBC-8045-E9E8323685EB@xyratex.com>
	<5089AB8A.9070402@llnl.gov>
	<34F2324A-7C99-4B59-AB9D-9BDB60912BF3@xyratex.com>
	<20121025215243.GF2555@llnl.gov>
	<CAJz=VjHoqmXKWe+YbHmN-SnaWECUBK39NTaVPhEA12wcg_qTUA@mail.gmail.com>
	<508A4F5A.8000207@xyratex.com>
Message-ID: <CAJz=VjFtyj_tL9gXBZP2faXd-VAk8jeRbEmiEdL8h64ecYiY9g@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Roman,

> Few samples, which comparably hard to implement on bash than on other
> languages from my point of view (especially via evolving tes-framework.sh):

I don't really want to engage in a code battle I would definitely
loose, and I'm also not very familiar with the current test framework
inner workings, but here are a few points.

> - how could be implemented for current framework random and repeatable
> test execution?

Not sure what's required here, but how about storing the list of tests
in a Bash array, generating a list of random indexes, and using it to
loop over the test array?

> - how could be implemented observation of remote node status while
> command executed on it and killed it by timeout?

One can read a SSH output stream with the appropriate redirections and
act upon results, stdout or stderr contents, and/or return codes. The
read Bash builtin takes a timeout parameter, and "timeout" is also an
often overlooked coreutils command. :)

> - how simple add machine-readable meta information for test, e.f. tags
> and timeouts?

With an associative array, for instance:
$ declare -A TESTS
$ TESTS=( [test1]="tag1:timeout1"
        [test2]="tag2:timeout2"
        [test3]="tag3:timeout3" )
$ for test in ${!TESTS[@]}; do
        value=${TESTS[$test]}
        tag=${value%%:*}
        timeout=${value##*:}
        printf "%s is tagged with %s and has a timeout of %s.\n" $test
$tag $timeout
done
test1 is tagged with tag1 and has a timeout of timeout1.
test2 is tagged with tag2 and has a timeout of timeout2.
test3 is tagged with tag3 and has a timeout of timeout3.

Cheers,
--
Kilian
