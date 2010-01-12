From: Alex Zhuravlev <Alex.Zhuravlev@Sun.COM>
Date: Tue, 12 Jan 2010 06:42:38 +0300
Subject: [Lustre-devel] SOM questions
In-Reply-To: <AC682480-691F-46C8-906D-8818A1C8FC18@Sun.COM>
References: <078f01ca8e31$22ff9f80$68fede80$@com>
	<05A3FFE9-1549-4B97-A9C3-4B82113E56AE@Sun.COM>
	<4B4B4801.7070509@sun.com>
	<AC682480-691F-46C8-906D-8818A1C8FC18@Sun.COM>
Message-ID: <4B4BEFAE.7030907@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 1/12/10 12:59 AM, Vitaly Fertman wrote:
> what do you mean stable? If you mean they are not going to change,
> this is exactly what OST doesn't know because it doesn't know if file
> is opened.

let me rephrase it: stable means there is no pending (cached) IO on
the clients and all locally cached (on OST) changes are committed to disk.

> could you clarify how you can block IO from "lost" clients without
> writing some id (VBR id?) to OST objects and not waiting for this
> change to commit before updating MDS with new attributes?

this is related but different issue discussed in "SOM safety" :) we
consider at least 3 options for that.

thanks, Alex
