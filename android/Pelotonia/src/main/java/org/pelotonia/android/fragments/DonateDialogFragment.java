package org.pelotonia.android.fragments;

import android.app.AlertDialog;
import android.app.Dialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.support.v4.app.DialogFragment;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.EditText;

import org.pelotonia.android.R;

public class DonateDialogFragment extends DialogFragment{

    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());

        LayoutInflater inflater = getActivity().getLayoutInflater();

        // Inflate and set the layout for the dialog
        // Pass null as the parent view because its going in the dialog layout
        final View v = inflater.inflate(R.layout.donate_dialog, null);
        builder.setView(v)
                // Add action buttons
                .setPositiveButton("Send", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int id) {
                        EditText amount = (EditText) v.findViewById(R.id.donate_amount);
                        EditText email = (EditText) v.findViewById(R.id.email_address);
                        Intent emailIntent = new Intent(Intent.ACTION_SENDTO, Uri.fromParts(
                                "mailto", email.getText().toString(), null));
                        emailIntent.putExtra(Intent.EXTRA_SUBJECT, "GIMME THAT MONEY!");
                        emailIntent.putExtra(Intent.EXTRA_TEXT, amount.getText().toString());
                        startActivity(Intent.createChooser(emailIntent, "Send email..."));
                    }
                })
                .setNegativeButton("Cancel", new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        DonateDialogFragment.this.getDialog().cancel();
                    }
                });
        return builder.create();
    }}
