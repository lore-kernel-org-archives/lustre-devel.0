From: Drokin, Oleg <oleg.drokin@intel.com>
Date: Mon, 27 Jul 2015 14:16:40 +0000
Subject: [lustre-devel] Expanding Build/Test Coverage for community tree
Message-ID: <8FD97F7B-BF6F-4DB9-8A87-A88BF3683EC4@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

I have been thinking about ways to extend our build/test coverage beyond
the capacity and composition of the HPDD test cluster.

Without participating in continuous build/testing, it is easy for
regressions affecting options used in the community (architectures, Linux
distros or lnds, say) to creep in and only be reported after the
responsible changes have landed (and perhaps even a release has gone out)

In order to alleviate this somehow, I created a small howto with a
handful of scripts that would allow all interested parties to insert their
own builders and test scenarios into process from comfort of their own data
centers and without full blown additional Jenkins instances and such.

The scripts are pretty primitive and single threaded (mostly geared for
build testing now), but they do their intended job. All enhancements to
make them better handle testing, integrate with web servers to post better
output and such are also greatly appreciated.

The howto could be located at http://wiki.lustre.org/Simple_Gerrit_Builder_Howto

Thanks.

Bye,
    Oleg
