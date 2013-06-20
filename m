From: White, Cliff <cliff.white@intel.com>
Date: Thu, 20 Jun 2013 21:15:25 +0000
Subject: [Lustre-devel] Lustre 2.4 Release
In-Reply-To: <CALuPYL1WgGcY=8uikyCsa_Tp5GNqqj0+EysJ3r8baMGLsCL9iA@mail.gmail.com>
Message-ID: <CDE8BE97.5D32%cliff.white@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org



From: Indivar Nair <indivar.nair at techterra.in<mailto:indivar.nair@techterra.in>>
Date: Thursday, June 20, 2013 10:38 AM
To: "Dilger, Andreas" <andreas.dilger at intel.com<mailto:andreas.dilger@intel.com>>
Cc: "lustre-devel at lists.lustre.org<mailto:lustre-devel@lists.lustre.org>" <lustre-devel at lists.lustre.org<mailto:lustre-devel@lists.lustre.org>>
Subject: Re: [Lustre-devel] Lustre 2.4 Release

Ok. The diagram seems to suggest that 2.4.0 would be first maintenance release.

Anyways...

So I will be able to make an inplace upgrade from 2.4.0 to 2.4.1 when it is released.
i.e. no re-installation of OS or reformatting OSTs when I move to 2.4.1.
Just upgrading the Lustre Kernel and Lustre Packages to 2.4.1 should do. right?

Yes, that is the meaning of a maintenance release. Any upgrade from Lustre X.Y.N to X.Y.N+1  will not require re-formatting.
However, we track vendor kernel bug fixes in our kernels, so a maintenance release will require a kernel change, but should not impact the OS install otherwise.
Cliffw



Regards,


Indivar Nair



On Thu, Jun 20, 2013 at 9:54 PM, Dilger, Andreas <andreas.dilger at intel.com<mailto:andreas.dilger@intel.com>> wrote:
On 2013/20/06 6:21 AM, "Indivar Nair" <indivar.nair at techterra.in<mailto:indivar.nair@techterra.in>> wrote:

>Hi ...,
>
>
>Lustre 2.4 was supposed to be released as a "Maintenance Release' -
>
>  https://wiki.hpdd.intel.com/display/PUB/Community+Lustre+Roadmap
>
>so how come it has been released as a 'Feature Release'?
>
>  https://wiki.hpdd.intel.com/display/PUB/Lustre+Releases
>
>
>Will it be moved to 'Maintenance Release' later?

The 2.4.0 release is one of the 6-month feature releases.
2.4.1 will be the first maintenance release on that branch.

Cheers, Andreas
--
Andreas Dilger

Lustre Software Architect
Intel High Performance Data Division
