Name:           nvidia-addons
Version:        0.2
Release:        1%{?dist}
Summary:        Additional files for nvidia driver support

License:        MIT
URL:            https://github.com/rsturla/eternal-linux/akmods/nvidia

BuildArch:      noarch
Supplements:    mokutil policycoreutils

Source0:        eternal-akmods.der
Source1:        nvidia-container-toolkit.repo
Source2:        nvidia-container.pp

%description
Adds various runtime files for nvidia support. These include a key for importing with mokutil to enable secure boot for nvidia kernel modules

%prep
%setup -q -c -T


%build
install -Dm0644 %{SOURCE0} %{buildroot}%{_datadir}/eternal-linux/%{_sysconfdir}/pki/akmods/certs/eternal-akmods.der
install -Dm0644 %{SOURCE1} %{buildroot}%{_datadir}/eternal-linux/%{_sysconfdir}/yum.repos.d/nvidia-container-toolkit.repo
install -Dm0644 %{SOURCE2} %{buildroot}%{_datadir}/eternal-linux/%{_datadir}/selinux/packages/nvidia-container.pp

sed -i 's@enabled=1@enabled=0@g' %{buildroot}%{_datadir}/eternal-linux/%{_sysconfdir}/yum.repos.d/nvidia-container-toolkit.repo

install -Dm0644 %{buildroot}%{_datadir}/eternal-linux/%{_sysconfdir}/pki/akmods/certs/eternal-akmods.der     %{buildroot}%{_sysconfdir}/pki/akmods/certs/eternal-akmods.der
install -Dm0644 %{buildroot}%{_datadir}/eternal-linux/%{_sysconfdir}/yum.repos.d/nvidia-container-toolkit.repo     %{buildroot}%{_sysconfdir}/yum.repos.d/nvidia-container-toolkit.repo
install -Dm0644 %{buildroot}%{_datadir}/eternal-linux/%{_datadir}/selinux/packages/nvidia-container.pp             %{buildroot}%{_datadir}/selinux/packages/nvidia-container.pp

%files
%attr(0644,root,root) %{_datadir}/eternal-linux/%{_sysconfdir}/pki/akmods/certs/eternal-akmods.der
%attr(0644,root,root) %{_datadir}/eternal-linux/%{_sysconfdir}/yum.repos.d/nvidia-container-toolkit.repo
%attr(0644,root,root) %{_datadir}/eternal-linux/%{_datadir}/selinux/packages/nvidia-container.pp
%attr(0644,root,root) %{_sysconfdir}/pki/akmods/certs/eternal-akmods.der
%attr(0644,root,root) %{_sysconfdir}/yum.repos.d/nvidia-container-toolkit.repo
%attr(0644,root,root) %{_datadir}/selinux/packages/nvidia-container.pp

%changelog
* Sat May 27 2023 Robert Sturla <robertsturla@outlook.com>
- Initial build
