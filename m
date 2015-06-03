From: Patrick Farrell <paf@cray.com>
Date: Wed, 3 Jun 2015 13:32:05 -0500
Subject: [lustre-devel] Lustre and libreadline
Message-ID: <556F4825.1050408@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Good afternoon,

Cray has recently discovered that 'lfs getstripe' crashes with a null 
pointer if it is not built with libreadline (Found in 'readline-devel').

When built without libreadline, Lustre uses its own implementation of 
the readline components it needs.  (Look for "HAVE_LIBREADLINE" in 
libcfs/libcfs/util/parser.c)  This is the source of the null pointer.

I think libreadline should be available on every platform we wish to 
build Lustre on, so I'd rather not fix the broken internal version of 
it.  Given that, is there any objection to adding an explicit 
BuildRequires to the spec, making it mandatory in the config process, 
and removing all traces of Lustre's internal readline implementation?  
If not, I'll open a Jira ticket to do this.

- Patrick
