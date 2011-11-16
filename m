From: Bruce Korb <bruce_korb@xyratex.com>
Date: Wed, 16 Nov 2011 14:22:38 -0800
Subject: [Lustre-devel] lustre-devel  packaging - LU-482
In-Reply-To: <CAE7B612.1389%bruce_korb@xyratex.com>
Message-ID: <CAE97569.14B4%bruce_korb@xyratex.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Andreas,

I did do a little more due diligence:

On 11/15/11 7:22 AM, Bruce Korb wrote:
>>My main question would be - do you _need_ to have access to all of the
>>headers that you included, or did you simply include all of the headers
>>because that was the easiest thing to do?  Doing a simple check on the
>>current master tree, it appears you just copied all of the headers in
>>libcfs/include, lnet/include, and lustre/include (which total 186 files).
>
>Lets assume I did a minimal approach and only included the necessary


  libcfs/libcfsutil.h
  lnet/lnetctl.h
  lustre/liblustreapi.h
  lustre/lustre_idl.h
  test.h
  utils/obdctl.h

These are the headers directly #include-d by our "utility"

that live in the lustre tree.  They likely pull in several more.
As I said elsewhere somewhere, unless the libcfs, lnet, lustre and utils
components of lustre know that these are exported via an unambiguous
mechanism, installing only the minimal subset will be prone to problems.
A better way is to have them stage the headers and run a validation that
they are all both self-sufficient and idempotent, meaning that any
requisite headers are also staged and they are all guarded with duplicate
inclusion guards.  This can be done with a trivial script.

I can make this part of the "lustre-devel package" project.  I was trying
to limit scope by installing everything in sight.  At least for now.
